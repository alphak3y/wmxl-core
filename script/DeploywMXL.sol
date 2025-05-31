// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Script } from "forge-std/Script.sol";

import { wMXL } from "src/wmxl/wMXL.sol";
import { RegistryAccess } from "src/access/RegistryAccess.sol";
import { WrappedMToken } from "wrapped-m-token/src/WrappedMToken.sol";

import {
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeploywMXL is Script {
    address internal constant _M_TOKEN = 0x0000000000000000000000000000000000000000; // Mainnet M Token
    address internal constant _WMXL_ADMIN = 0xC2b3075fB1AC9f5eCc1e2C07dA8bcCC43e7083fb; // Last multisig
    address internal constant _WRAPPED_M_ADDRESS = 0x0000000000000000000000000000000000000000; // Mainnet Wrapped M

    function run() external {
        if (_M_TOKEN == address(0)) revert("M_TOKEN not set");
        if (_WMXL_ADMIN == address(0)) revert("WMXL_ADMIN not set");
        if (_WRAPPED_M_ADDRESS == address(0)) revert("WRAPPED_M_ADDRESS not set");

        address deployer_ = vm.rememberKey(vm.envUint("PRIVATE_KEY"));

        vm.startBroadcast(deployer_);

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
            _WRAPPED_M_ADDRESS,
            registryAccessAddress
        );
        address(new TransparentUpgradeableProxy(wMXLImplementation, _WMXL_ADMIN, wMXLData));

        vm.stopBroadcast();
    }
}
