// SPDX-License-Identifier: Apache License, Version 2.0

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

import { ISetToken } from "@setprotocol/index-coop-contracts/contracts/interfaces/ISetToken.sol";
import { PreciseUnitMath } from "@setprotocol/index-coop-contracts/contracts/lib/PreciseUnitMath.sol";

import { MutualUpgrade } from "@setprotocol/index-coop-contracts/contracts/lib/MutualUpgrade.sol";
import { IStreamingFeeModule } from "@setprotocol/index-coop-contracts/contracts/interfaces/IStreamingFeeModule.sol";

import { ITradeModule } from "../interfaces/ITradeModule.sol";
import { ITrigger } from "../interfaces/ITrigger.sol";

contract MultipleMovingAverageManager is MutualUpgrade {
    using Address for address;
    using SafeMath for uint256;
    using PreciseUnitMath for uint256;
    using SafeCast for int256;

    /* ============ Events ============ */

    event FeesAccrued(
        uint256 _totalFees,
        uint256 _operatorTake,
        uint256 _methodologistTake
    );

    event MethodologistChanged(
        address _oldMethodologist,
        address _newMethodologist
    );

    event OperatorChanged(
        address _oldOperator,
        address _newOperator
    );

    event RiskStatusChanged(
        bool _wasBullish,
        bool _nowBullish
    );

    /* ============ Modifiers ============ */

    modifier onlyOperator() {
        require(msg.sender == operator, "Must be operator");
        _;
    }

    modifier onlyMethodologist() {
        require(msg.sender == methodologist, "Must be methodologist");
        _;
    }

    /* ============ State Variables ============ */

    ISetToken public setToken;

    ITradeModule public tradeModule;

    IStreamingFeeModule public feeModule;

    ITrigger public trigger;

    address public operator;

    address public methodologist;

    uint256 public operatorFeeSplit;

    address public riskOnComponent;

    address public riskOffComponent;

    bool public isBullish;

    /* ============ Constructor ============ */

    constructor(
        ISetToken _setToken,
        ITradeModule _tradeModule,
        IStreamingFeeModule _feeModule,
        ITrigger _trigger,
        address _operator,
        address _methodologist,
        uint256 _operatorFeeSplit,
        address _riskOnComponent,
        address _riskOffComponent,
        bool _isBullish
    )
        public
    {
        require(
            _operatorFeeSplit <= PreciseUnitMath.preciseUnit(),
            "Operator Fee Split must be less than 1e18"
        );

        require(
            _setToken.isComponent(_riskOnComponent),
            "Risk On component must be in Set Token"
        );

        require(
            _setToken.isComponent(_riskOffComponent),
            "Risk Off component must be in Set Token"
        );

        setToken = _setToken;
        tradeModule = _tradeModule;
        feeModule = _feeModule;
        trigger = _trigger;
        operator = _operator;
        methodologist = _methodologist;
        operatorFeeSplit = _operatorFeeSplit;
        riskOnComponent = _riskOnComponent;
        riskOffComponent = _riskOffComponent;
        isBullish = _isBullish;
    }

    /* ============ External Functions ============ */

    function accrueFeeAndDistribute() public {
        feeModule.accrueFee(setToken);

        uint256 setTokenBalance = setToken.balanceOf(address(this));

        uint256 operatorTake = setTokenBalance.preciseMul(operatorFeeSplit);
        uint256 methodologistTake = setTokenBalance.sub(operatorTake);

        setToken.transfer(operator, operatorTake);

        setToken.transfer(methodologist, methodologistTake);

        emit FeesAccrued(setTokenBalance, operatorTake, methodologistTake);
    }
    
    function updateManager(address _newManager) external mutualUpgrade(operator, methodologist) {
        require(_newManager != address(0), "Zero address not valid");
        setToken.setManager(_newManager);
    }

    function addModule(address _module) external onlyOperator {
        setToken.addModule(_module);
    }

    function removeModule(address _module) external onlyOperator {
        setToken.removeModule(_module);
    }

    function rebalance(
        string memory _exchangeName,
        bytes memory _data
    ) public {

        bool updateIsBullish = trigger.isBullish();

        if (isBullish && !updateIsBullish) { 
            
            // Switch to bearish allocation
            uint sendUnits = setToken.getDefaultPositionRealUnit(riskOnComponent).toUint256();
            _trade(_exchangeName, riskOnComponent, sendUnits, riskOffComponent, 0, _data);
            emit RiskStatusChanged(isBullish, updateIsBullish);
            isBullish = updateIsBullish;
        } else if (!isBullish && updateIsBullish) { 
            
            // Switch to bullish allocation
            uint sendUnits = setToken.getDefaultPositionRealUnit(riskOffComponent).toUint256();
            _trade(_exchangeName, riskOffComponent, sendUnits, riskOnComponent, 0, _data);
            emit RiskStatusChanged(isBullish, updateIsBullish);
            isBullish = updateIsBullish;
        } 
    }

    function updateStreamingFee(uint256 _newFee) external onlyMethodologist {
        feeModule.updateStreamingFee(setToken, _newFee);
    }

    function updateFeeRecipient(address _newFeeRecipient) external mutualUpgrade(operator, methodologist) {
        feeModule.updateFeeRecipient(setToken, _newFeeRecipient);
    }

    function updateFeeSplit(uint256 _newFeeSplit) external mutualUpgrade(operator, methodologist) {
        require(
            _newFeeSplit <= PreciseUnitMath.preciseUnit(),
            "Operator Fee Split must be less than 1e18"
        );

        // Accrue fee to operator and methodologist prior to new fee split
        accrueFeeAndDistribute();
        operatorFeeSplit = _newFeeSplit;
    }

    function updateTradeModule(ITradeModule _newTradeModule) external onlyOperator {
        tradeModule = _newTradeModule;
    }

    function updateStreamingFeeModule(IStreamingFeeModule _newStreamingFeeModule) external onlyOperator {
        feeModule = _newStreamingFeeModule;
    }

    function updateMethodologist(address _newMethodologist) external onlyMethodologist {
        emit MethodologistChanged(methodologist, _newMethodologist);
        methodologist = _newMethodologist;
    }

    function updateOperator(address _newOperator) external onlyOperator {
        emit OperatorChanged(operator, _newOperator);
        operator = _newOperator;
    }

    /* ============ Internal Functions ============ */

    /**
     * @notice Executes a trade on a supported DEX. Only callable by the operator. 
     * @dev Although the SetToken units are passed in for the send and receive quantities, the total quantity
     * sent and received is the quantity of SetToken units multiplied by the SetToken totalSupply.
     *
     * @param _exchangeName         Human readable name of the exchange in the integrations registry
     * @param _sendToken            Address of the token to be sent to the exchange
     * @param _sendQuantity         Units of token in SetToken sent to the exchange
     * @param _receiveToken         Address of the token that will be received from the exchange
     * @param _minReceiveQuantity   Min units of token in SetToken to be received from the exchange
     * @param _data                 Arbitrary bytes to be used to construct trade call data
     */
    function _trade(
        string memory _exchangeName,
        address _sendToken,
        uint256 _sendQuantity,
        address _receiveToken,
        uint256 _minReceiveQuantity,
        bytes memory _data
    ) internal {
        tradeModule.trade(setToken, _exchangeName, _sendToken, _sendQuantity, _receiveToken, _minReceiveQuantity, _data);
    }
}