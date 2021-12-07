// SPDX-License-Identifier: Apache License, Version 2.0
// Inspired by https://github.com/SetProtocol/set-protocol-strategies/blob/master/contracts/managers/triggers/ITrigger.sol

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

interface ITrigger {
    function isBullish()
        external
        view
        returns (bool);
}