// SPDX-License-Identifier: Apache License, Version 2.0
// Inspired by https://github.com/SetProtocol/set-protocol-strategies/blob/master/contracts/managers/triggers/MovingAverageCrossoverTrigger.sol

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";

import { IMetaOracle } from "../interfaces/IMetaOracle.sol";

contract MultipleMovingAverageCrossoverTrigger  
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */
    IMetaOracle public movingAveragePriceFeedInstance;
    uint256[] public longTermMovingAverages;
    uint256[] public shortTermMovingAverages;
    bool public uncertainIsBullish;

    /* ============ Constructor ============ */
    constructor(
        IMetaOracle _movingAveragePriceFeedInstance,
        uint256[] memory _longTermMovingAverages,
        uint256[] memory _shortTermMovingAverages,
        bool _uncertainIsBullish
    )
        public 
    {
        movingAveragePriceFeedInstance = _movingAveragePriceFeedInstance;
        longTermMovingAverages = _longTermMovingAverages;
        shortTermMovingAverages = _shortTermMovingAverages;
        uncertainIsBullish = _uncertainIsBullish;
    }

    /* ============ External ============ */
    function isBullish() external view returns (bool) {

        uint256 firstLongAverage = movingAveragePriceFeedInstance.read(longTermMovingAverages[0]);
        uint256 minLongGroup = firstLongAverage;
        uint256 maxLongGroup = firstLongAverage;
        for (uint256 i=1; i<longTermMovingAverages.length; i++) 
        {
            uint256 valLong = movingAveragePriceFeedInstance.read(longTermMovingAverages[i]);
            if (minLongGroup > valLong) {
                minLongGroup = valLong;
            }
            if (maxLongGroup < valLong) {
                maxLongGroup = valLong;
            }
        }

        uint256 firstShortAverage = movingAveragePriceFeedInstance.read(shortTermMovingAverages[0]);
        uint256 minShortGroup = firstShortAverage;
        uint256 maxShortGroup = firstShortAverage;
        for (uint256 i=1; i<shortTermMovingAverages.length; i++) 
        {
            uint256 valShort = movingAveragePriceFeedInstance.read(shortTermMovingAverages[i]);
            if (minShortGroup > valShort) {
                minShortGroup = valShort;
            }
            if (maxShortGroup < valShort) {
                maxShortGroup = valShort;
            }
        }

        if (minShortGroup > maxLongGroup) {
            return true;
        } else if (maxShortGroup < minLongGroup) {
            return false;
        } else {
            return uncertainIsBullish;
        }
    }
}