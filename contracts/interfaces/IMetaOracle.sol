// SPDX-License-Identifier: Apache License, Version 2.0
// Inspired by https://github.com/SetProtocol/set-protocol-oracles/blob/master/contracts/meta-oracles/interfaces/IMetaOracleV2.sol

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

interface IMetaOracle {
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (uint256);
}