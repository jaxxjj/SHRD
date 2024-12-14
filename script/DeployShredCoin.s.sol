// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {ShredCoin} from "../src/ShredCoin.sol";

contract DeployShredCoin is Script {
    // Testnet Chain IDs
    uint32 constant ARBITRUM_SEPOLIA_EID = 421614;
    uint32 constant BASE_SEPOLIA_EID = 84532;
    uint32 constant ETH_SEPOLIA_EID = 11155111;

    // LayerZero endpoints
    mapping(uint32 => address) public lzEndpoints;
    
    // Deployed ShredCoin addresses on each chain
    mapping(uint32 => address) public deployedAddresses;

    function setUp() public {
        // Testnet EndpointV2 addresses
        lzEndpoints[ARBITRUM_SEPOLIA_EID] = 0x6EDCE65403992e310A62460808c4b910D972f10f;  
        lzEndpoints[BASE_SEPOLIA_EID] = 0x6EDCE65403992e310A62460808c4b910D972f10f;      
        lzEndpoints[ETH_SEPOLIA_EID] = 0x6EDCE65403992e310A62460808c4b910D972f10f;      
    }

    function run() public {
        // 1. Deploy to Ethereum Sepolia
        deployToChain(ETH_SEPOLIA_EID);
        
        // 2. Deploy to Base Sepolia
        deployToChain(BASE_SEPOLIA_EID);
        
        // 3. Deploy to Arbitrum Sepolia
        deployToChain(ARBITRUM_SEPOLIA_EID);
        
        // 4. Set up peers between chains
        setupPeers();
    }

    function deployToChain(uint32 chainId) internal {
        // Load chain-specific RPC URL and private key
        string memory rpcUrl = vm.envString(string.concat(getChainPrefix(chainId), "_RPC_URL"));
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Create deployer address
        address owner = vm.addr(deployerPrivateKey);
        
        // Switch to chain's RPC
        vm.createSelectFork(rpcUrl);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ShredCoin
        ShredCoin shredCoin = new ShredCoin(
            owner,
            lzEndpoints[chainId],
            owner
        );
        
        vm.stopBroadcast();
        
        // Store deployed address
        deployedAddresses[chainId] = address(shredCoin);
        
        console2.log(
            string.concat("ShredCoin deployed on ", getChainName(chainId), " at: "),
            address(shredCoin)
        );
    }

    function setupPeers() internal {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Set up peers between all chains
        uint32[3] memory chains = [ETH_SEPOLIA_EID, BASE_SEPOLIA_EID, ARBITRUM_SEPOLIA_EID];
        
        for(uint i = 0; i < chains.length; i++) {
            for(uint j = 0; j < chains.length; j++) {
                if(i != j) {
                    uint32 srcChainId = chains[i];
                    uint32 dstChainId = chains[j];
                    
                    // Switch to source chain
                    string memory rpcUrl = vm.envString(
                        string.concat(getChainPrefix(srcChainId), "_RPC_URL")
                    );
                    vm.createSelectFork(rpcUrl);
                    
                    vm.startBroadcast(deployerPrivateKey);
                    
                    // Get contracts
                    ShredCoin srcShredCoin = ShredCoin(deployedAddresses[srcChainId]);
                    
                    // Set peer
                    bytes32 remotePeer = addressToBytes32(deployedAddresses[dstChainId]);
                    srcShredCoin.setPeer(dstChainId, remotePeer);
                    
                    vm.stopBroadcast();
                    
                    console2.log(
                        string.concat(
                            "Set peer on ",
                            getChainName(srcChainId),
                            " for ",
                            getChainName(dstChainId)
                        )
                    );
                }
            }
        }
    }

    // Helper functions
    function addressToBytes32(address addr) public pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
    
    function getChainPrefix(uint32 chainId) internal pure returns (string memory) {
        if(chainId == ETH_SEPOLIA_EID) return "ETH_SEPOLIA";
        if(chainId == BASE_SEPOLIA_EID) return "BASE_SEPOLIA";
        if(chainId == ARBITRUM_SEPOLIA_EID) return "ARB_SEPOLIA";
        revert("Unknown chain");
    }
    
    function getChainName(uint32 chainId) internal pure returns (string memory) {
        if(chainId == ETH_SEPOLIA_EID) return "Ethereum Sepolia";
        if(chainId == BASE_SEPOLIA_EID) return "Base Sepolia";
        if(chainId == ARBITRUM_SEPOLIA_EID) return "Arbitrum Sepolia";
        revert("Unknown chain");
    }
}