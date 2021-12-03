// SPDX-License-Identifier: Apache License, Version 2.0
// Code from Set Protocol https://github.com/SetProtocol/index-coop-smart-contracts/blob/master/contracts/interfaces/IAdapter.sol
// No changes

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

import { IBaseManager } from "./IBaseManager.sol";

interface IAdapter {
    function manager() external view returns (IBaseManager);
}