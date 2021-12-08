# Multiple Moving Average Set Token

Utilize [Set Protocol V2](https://docs.tokensets.com/) and [Uniswap V3 oracles](https://docs.uniswap.org/protocol/concepts/V3-overview/oracle) to tokenize a smart contract managed multiple moving average crossover trading strategy.

## Installing Dependencies

### Node

```bash
npm install @openzeppelin/contracts@3.1.0
```

```bash
npm install @setprotocol/set-protocol-v2
```

```bash
npm install @setprotocol/index-coop-contracts
```

```bash
npm install @uniswap/v3-core
```

## Strategy Description 

### Indicator

Consider two groups of moving averages: S, a group of n short term moving averages and L, a group of m long term moving averages. 

S = [S1, S2, ..., Sn]

L = [L1, L2, ..., Lm]

An indicator MMA() can be constructed as follows
- bullish if min(S) > max(L)
- bearish if max(S) < min(L)
- uncertain otherwise

The uncertain case, when the short term and long term groups of moving averages overlap, can be considered either bullish (risk-on) or bearish (risk-off) depending on manager preference. 

### Two Assets Strategy

With a risk-on asset (ex: $ETH) and a risk-off asset (ex: $USDC) a strategy could be constructed as follows
- hold $ETH when MMA($ETHUSDC) is bullish
- hold $USDC when MMA($ETHUSDC) is bearish or uncertain

## Future Steps

- Place trades efficiently
- Gas optimization in trigger
- Add AAVE lending (wrapping)

## Acknowledgements
* [Set Protocol V2](https://docs.tokensets.com/): [[GitHub](https://github.com/SetProtocol/set-protocol-v2)]
* [Uniswap V3](https://uniswap.org/whitepaper-v3.pdf): [[GitHub](https://github.com/Uniswap/v3-core)] [[Oracle Documentation](https://docs.uniswap.org/protocol/concepts/V3-overview/oracle)]
