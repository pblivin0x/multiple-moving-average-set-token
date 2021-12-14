const MultipleMovingAverageCrossoverIndicator = artifacts.require("MultipleMovingAverageCrossoverIndicator");

module.exports = function (deployer) {

    // Ethereum mainnet network addresses

    // Uniswap V3 WETH-USDC 0.3% pool
    pool = '0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8';

    // Long term moving average durations in seconds
    // [3.5 days, 3.0 days, 2.5 days, 2.0 days]
    const longTermTimePeriods = [302400, 259200, 216000, 172800];

    // Short term moving average durations in seconds 
    // [12 hours, 9 hours, 6 hours, 3 hours]
    const shortTermTimePeriods = [43200, 32400, 21600, 10800];

    // Whether to consider group overlap as bullish or bearish
    const uncertainIsBullish = false;

    // 
    const operator =  '0xD20673d9c07BaA5400B9DF075C3077DfE75A1a1F';

    deployer.deploy(MultipleMovingAverageCrossoverIndicator,
                    pool,
                    longTermTimePeriods,
                    shortTermTimePeriods,
                    uncertainIsBullish,
                    operator);
  };