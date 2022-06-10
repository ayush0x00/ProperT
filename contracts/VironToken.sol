pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VironToken is ERC20{
    address admin;
    
    constructor() ERC20("Viron","VE"){
        admin=msg.sender;
    }

    function mint() public{ //for minting tokens

    }

    function mintTokenToVault() public{

    }

}