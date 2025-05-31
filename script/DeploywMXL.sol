// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.26;

import { Script } from "forge-std/Script.sol";

import { wMXL } from "src/wmxl/wMXL.sol";
import { RegistryAccess } from "src/access/RegistryAccess.sol";
import { WrappedMToken } from "wrapped-m-token/src/WrappedMToken.sol";

import {
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeploywMXLScript is Script {
    address internal constant _M_TOKEN = 0x0000000000000000000000000000000000000000; // Mainnet M Token
    address internal constant _WMXL_ADMIN = 0xc2b3075fb1ac9f5ecc1e2c07da8bccc43e7083fb; // Last multisig

    function run() external {
        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        vm.startBroadcast(deployer_);

        // Deploy Wrapped M Token implementation
        address wrappedMImplementation = address(new WrappedMToken(_M_TOKEN, _WMXL_ADMIN));
        
        // Deploy Wrapped M Token proxy
        address wrappedMAddress = address(new TransparentUpgradeableProxy(wrappedMImplementation, _WMXL_ADMIN, ""));

        // Deploy RegistryAccess implementation
        address registryAccessImplementation = address(new RegistryAccess());
        
        // Deploy RegistryAccess proxy and initialize
        bytes memory registryAccessData = abi.encodeWithSignature(
            "initialize(address)",
            _WMXL_ADMIN
        );
        address registryAccessAddress = address(new TransparentUpgradeableProxy(registryAccessImplementation, _WMXL_ADMIN, registryAccessData));

        // Deploy wMXL implementation
        address wMXLImplementation = address(new wMXL());
        
        // Deploy wMXL proxy and initialize with the deployed registry access
        bytes memory wMXLData = abi.encodeWithSignature(
            "initialize(address,address)",
            wrappedMAddress,
            registryAccessAddress
        );
        address(new TransparentUpgradeableProxy(wMXLImplementation, _WMXL_ADMIN, wMXLData));

        vm.stopBroadcast();
    }
}
