// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.23;

import { Script } from "forge-std/Script.sol";
import { WrappedMToken } from "wrapped-m-token/src/WrappedMToken.sol";
import {
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployWrappedM is Script {
    address internal constant _M_TOKEN = 0x0000000000000000000000000000000000000000; // Mainnet M Token
    address internal constant _WMXL_ADMIN = 0xc2b3075fb1ac9f5ecc1e2c07da8bccc43e7083fb; // Last multisig

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        vm.startBroadcast(deployer_);

        // Deploy Wrapped M Token implementation
        address wrappedMImplementation = address(new WrappedMToken(_M_TOKEN, _WMXL_ADMIN));
        
        // Deploy Wrapped M Token proxy
        address wrappedMAddress = address(new TransparentUpgradeableProxy(wrappedMImplementation, _WMXL_ADMIN, ""));

        vm.stopBroadcast();

        // Log the deployed addresses
        console.log("WrappedM Implementation:", wrappedMImplementation);
        console.log("WrappedM Proxy:", wrappedMAddress);
    }
} 