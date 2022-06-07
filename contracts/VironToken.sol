pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./DefiContracts/VaultNFT.sol";

contract VironToken is ERC20,VaultNFT{
    address admin;
    VaultNFT vaultData;
    
    constructor(VaultNFT _vaultData) ERC20("Viron","VE"){
        admin=msg.sender;
        vaultData=_vaultData;
    }

    function mint() public{ //for minting tokens

    }

    function mintTokenToVault() public{

    }

}