# Multiple Moving Average Set Token

Utilize [Set Protocol V2](https://docs.tokensets.com/) to tokenize a multiple moving average trading strategy managed by smart contracts. 

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

## Strategy Description 

### Indicator

Consider two groups of moving averages: S, a group of 5 short term moving averages and L, a group of 5 long term moving averages. 

S = [S1, S2, S3, S4, S5]

L = [L1, L2, L3, L4, L5]

An indicator MMA() can be constructed as follows
- bullish if min(S) > max(L)
- bearish if max(S) < min(L)
- uncertain otherwise

The uncertain case, when the groups of moving averages overlap, can be considered either bullish (risk-on) or bearish (risk-off) depending on the application. 

### Two Assets Strategy

With a risk-on asset (ex: $ETH) and a risk-off asset (ex: $cUSDC) a strategy could be constructed as follows
- hold $ETH when MMA($ETHUSDC) is bullish
- hold $cUSDC when MMA($ETHUSDC) is bearish or uncertain

### Future Steps

- Implement Moving Average Oracle - need time series feed and moving average transformation
- Place trades efficiently
- Add AAVE lending (wrapping)

## Acknowledgements
* [Set Protocol V2](https://docs.tokensets.com/)