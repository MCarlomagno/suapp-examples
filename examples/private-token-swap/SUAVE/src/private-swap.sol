// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

import "suave-std/Gateway.sol";
import "suave-std/Suapp.sol";
import "suave-std/Context.sol";

interface Pool {
    // swap (token from, token to, amount)
    function swap(address, address, uint256) external returns (uint256);
}

contract PrivateSwap is Suapp {
    Gateway private gateway;

    event Swap(address from, address to, uint256 amount, uint256 resultAmount);

    constructor(string memory jsonrpc, address lp) {
        gateway = new Gateway(jsonrpc, lp);
    }

    function callback() external payable emitOffchainLogs {}

    function example() external returns (bytes memory) {
        bytes memory confidentialInputs = Context.confidentialInputs();
        (address from, address to, uint256 amount) = abi.decode(confidentialInputs, (address, address, uint256));

        Pool pool = Pool(address(gateway));

        uint256 resultAmount = pool.swap(from, to, amount);
        emit Swap(from, to, amount, resultAmount);

        return abi.encodeWithSelector(this.callback.selector);
    }
}
