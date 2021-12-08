// SPDX-License-Identifier: Apache License, Version 2.0

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

/**
 * @title   Multiple Moving Average Crossover Trigger
 * @author  pblivin0x
 * @notice  Consider two groups of moving averages: 
 *          S, a group of n short term moving averages and L, a group of m long term moving averages. 
 *
 *          S = [S1, S2, ..., Sn]
 *          L = [L1, L2, ..., Lm]
 *
 *          An indicator MMA() can be constructed as follows
 *          - bullish if min(S) > max(L)
 *          - bearish if max(S) < min(L)
 *          - uncertain otherwise
 *
 *          The uncertain case, when the short term and long term groups of moving averages overlap, 
 *          can be considered either bullish (risk-on) or bearish (risk-off) depending on manager preference.           
 */
contract MultipleMovingAverageCrossoverTrigger  
{
    /* ============ State Variables ============ */

    // Address of the Uniswap V3 pool to be used as moving average oracle
    IUniswapV3Pool public pool;

    // Boolean to indicate whether indicator uncertain case is bullish or bearish
    bool public uncertainIsBullish;

    // Number of moving average time periods supplied in the long group
    uint public m;

    // Number of moving average time periods supplied in the short group
    uint public n;

    // Full list of moving averages time periods: [L1, L2, ..., Lm, S1, S2, ..., Sn, 0]
    uint32[] public movingAverageTimePeriods;

    /* ============ Constructor ============ */

    /**
     * @notice Initialize new MultipleMovingAverageCrossoverTrigger instance
     * @param _pool                    Address of the Uniswap V3 pool to be used as moving average oracle
     * @param _longTermTimePeriods     Long term moving average time periods in seconds
     * @param _shortTermTimePeriods    Short term moving average time periods in seconds
     * @param _uncertainIsBullish      Boolean to indicate whether indicator uncertain case is bullish or bearish
     */
    constructor(
        IUniswapV3Pool _pool,
        uint32[] memory _longTermTimePeriods,
        uint32[] memory _shortTermTimePeriods,
        bool _uncertainIsBullish
    )
        public 
    {
        pool = _pool;
        uncertainIsBullish = _uncertainIsBullish;

        // Store number of moving averages in each group
        m = _longTermTimePeriods.length;
        n = _shortTermTimePeriods.length;

        // Collect all moving average durations and 0 in one array for UniswapV3 pool call
        for (uint i=0; i<m; i++) {
            movingAverageTimePeriods.push(_longTermTimePeriods[i]);
        }
        for (uint j=0; j<n; j++) {
            movingAverageTimePeriods.push(_shortTermTimePeriods[j]);
        }
        movingAverageTimePeriods.push(0);
    }

    /* ============ External ============ */

    /**
     * @notice Determines if Multiple Moving Average Crossover indicator is bullish at a given time
     *         Uses Uniswap V3 pool to collect time-weighted average prices in ticks
     *         Compares these to produce a signal
     * @return Boolean to represent if indicator is bullish
     */
    function isBullish() 
        external 
        view 
        returns (bool) 
    {
        // Gather cumulative tick values as of each `secondsAgos` from the current block timestamp 
        (int56[] memory tickCumulatives, ) = pool.observe(movingAverageTimePeriods);

        // Get minimum and maximum moving average from the long group
        int24 minLongMovingAverage = _getTwap(tickCumulatives[0], tickCumulatives[m+n], movingAverageTimePeriods[0]);
        int24 maxLongMovingAverage = minLongMovingAverage;
        for (uint i=1; i<m; i++) 
        {
            int24 longMovingAverage = _getTwap(tickCumulatives[i], tickCumulatives[m+n], movingAverageTimePeriods[i]);
            if (longMovingAverage < minLongMovingAverage) {
                minLongMovingAverage = longMovingAverage;
            }
            if (longMovingAverage > maxLongMovingAverage) {
                maxLongMovingAverage = longMovingAverage;
            }
        }

        // Get minimum and maximum moving average from the short group
        int24 minShortMovingAverage = _getTwap(tickCumulatives[m], tickCumulatives[m+n], movingAverageTimePeriods[m]);
        int24 maxShortMovingAverage = minShortMovingAverage;
        for (uint j=m+1; j<m+n; j++) 
        {
            int24 shortMovingAverage = _getTwap(tickCumulatives[j], tickCumulatives[m+n], movingAverageTimePeriods[j]);
            if (shortMovingAverage < minShortMovingAverage) {
                minShortMovingAverage = shortMovingAverage;
            }
            if (shortMovingAverage > maxShortMovingAverage) {
                maxShortMovingAverage = shortMovingAverage;
            }
        }

        // Compare and determine signal
        if (minShortMovingAverage > maxLongMovingAverage) {
            return true;
        } else if (maxShortMovingAverage < minLongMovingAverage) {
            return false;
        } else {
            return uncertainIsBullish;
        }
    }

    /* ============ Internal Functions ============ */

    /**
     * @notice Computes time-weighted average price in ticks from Uniswap V3 pool given tickCumulative and duration values
     * @param _historicalTickCumulative  Cumulative tick values as of each _duration seconds ago from the current block timestamp
     * @param _newTickCumulative         Cumulative tick values as of the current block timestamp
     * @param _duration                  Seconds ago from current block timestamp of _historicalTickCumulative
     * @return Time-weighted average price in ticks
     */
    function _getTwap(
        int56 _historicalTickCumulative,
        int56 _newTickCumulative,
        uint32 _duration
    ) 
        internal 
        pure 
        returns (int24) 
    {
        return int24((_historicalTickCumulative - _newTickCumulative) / _duration);
    }

}