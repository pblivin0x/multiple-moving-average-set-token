// SPDX-License-Identifier: Apache License, Version 2.0

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Math } from "@openzeppelin/contracts/math/Math.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/SafeCast.sol";

import { BaseExtension } from "@setprotocol/index-coop-contracts/contracts/lib/BaseExtension.sol";
import { IBaseManager } from "@setprotocol/index-coop-contracts/contracts/interfaces/IBaseManager.sol";
import { ISetToken } from "@setprotocol/index-coop-contracts/contracts/interfaces/ISetToken.sol";
import { PreciseUnitMath } from "@setprotocol/index-coop-contracts/contracts/lib/PreciseUnitMath.sol";

/**
 * @title MultipleMovingAverageStrategyExtension
 * @author pblivin0x
 */
contract MultipleMovingAverageStrategyExtension is BaseExtension {
    using Address for address;
    using PreciseUnitMath for uint256;
    using SafeMath for uint256;
    using SafeCast for int256;

    /* ============ Enums ============ */

    /* ============ Structs ============ */

    /* ============ Events ============ */

    /* ============ Modifiers ============ */

    /* ============ State Variables ============ */

    /* ============ Constructor ============ */

    /**
     * Instantiate addresses, methodology parameters, execution parameters, and incentive parameters.
     *
     * @param _manager                  Address of IBaseManager contract
    */
    constructor(
        IBaseManager _manager
    )
        public
        BaseExtension(_manager)
    {

    }

    /* ============ External Functions ============ */

    /* ============ External Getter Functions ============ */

    /* ============ Internal Functions ============ */
 }