// SPDX-License-Identifier: Apache License, Version 2.0
// Code from Set Protocol https://github.com/SetProtocol/index-coop-smart-contracts/blob/master/contracts/interfaces/IBaseManager.sol
// No changes

pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

import { ISetToken } from "./ISetToken.sol";

interface IBaseManager {
    function setToken() external returns(ISetToken);

    function methodologist() external returns(address);

    function operator() external returns(address);

    function interactManager(address _module, bytes calldata _encoded) external;

    function transferTokens(address _token, address _destination, uint256 _amount) external;
}