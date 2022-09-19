// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/StkAaveRetrieval.sol";
import "../src/interfaces/IStaticATokenLM.sol";
import "../src/interfaces/IAaveIncentivesController.sol";
import "oz/token/ERC20/IERC20.sol";

contract StkAaveRetrievalTest is Test {
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    address constant EMISSION_MANAGER = 0xEE56e2B3D491590B5b31738cC34d5232F378a8D5;
    uint256 mainnetFork;
    IERC20 STK_AAVE = IERC20(0x4da27a545c0c5B758a6BA100e3a049001de870f5);
    StkAaveRetrieval retrieval;
    
    // we're testing on a mainnet fork to simulate the state of the existing Aave and Balancer contracts
    function setUp() public {
        mainnetFork = vm.createSelectFork(vm.rpcUrl("mainnet"));
        retrieval = new StkAaveRetrieval();
    }

    // this test checks the "happy path", in which our function call succeeds, returning the stkAave to the multisig
    function testRetrievalEndToEnd() public {
        vm.selectFork(mainnetFork);
        vm.startPrank(EMISSION_MANAGER);
        IAaveIncentivesController(retrieval.INCENTIVE_CONTROLLER()).setClaimer(retrieval.BALANCER_DAO(), address(retrieval));
        vm.stopPrank();
        uint256 original_stkaave_balance = STK_AAVE.balanceOf(retrieval.BALANCER_MULTISIG());
        console.log("Original STKAAVE balance: %s", original_stkaave_balance);
        address multisig = retrieval.BALANCER_MULTISIG();
        vm.startPrank(multisig);
        retrieval.retrieve();
        vm.stopPrank();
        uint256 new_stkaave_balance = STK_AAVE.balanceOf(retrieval.BALANCER_MULTISIG());
        console.log("New STKAAVE balance: %s", new_stkaave_balance);
        assert(new_stkaave_balance > original_stkaave_balance);
    }
    
    // this test checks that the retrieval function fails if the caller is not the multisig
    function testNotFromMultisig() public {
        vm.selectFork(mainnetFork);
        vm.startPrank(EMISSION_MANAGER);
        IAaveIncentivesController(retrieval.INCENTIVE_CONTROLLER()).setClaimer(retrieval.BALANCER_DAO(), address(retrieval));
        vm.stopPrank();
        vm.expectRevert(bytes("Only Balancer Multisig"));
        retrieval.retrieve();
    }
    
    // this test checks that the retrieval function fails if the contract is not set as the claimer
    function testClaimerUnset() public {
        vm.selectFork(mainnetFork);
        address multisig = retrieval.BALANCER_MULTISIG();
        vm.startPrank(multisig);
        vm.expectRevert(bytes("Contract not set as claimer"));
        retrieval.retrieve();
        vm.stopPrank();
    }

}
