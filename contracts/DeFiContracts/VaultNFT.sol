// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../VironToken.sol";

contract VaultNFT is ERC1155{
    address owner;
    uint platinumVaultRate=20;
    uint goldVaultRate=25;
    uint diamondVaultRate=30;
    mapping (address=>Person) vaultOwnerInfo;
    VironToken viron;


    constructor(VironToken _viron) ERC1155("TokenURI string"){
        owner=msg.sender;
        viron=_viron;
    }
    /*
    1=> Platinum
    2=>gold
    3=>diamond
    */
    struct Person {
        address owner;
        uint platinumVaultCount;
        uint diamondVaultCount;
        uint goldVaultCount;
        uint vironAmountRemaining;
        uint lastWithdrawal;
    }

    function mintVault(uint _id,uint _amount) public{ //takes a vault id and mints it by amount
        if(vaultOwnerInfo[msg.sender].owner!=address(0)) revert("Sender already exisits");

        Person memory p=Person(msg.sender,0,0,0,0,0);
        if(_id==1) p.platinumVaultCount +=_amount; 
        else if(_id==2) p.goldVaultCount += _amount;
        else p.diamondVaultCount += _amount;

        _mint(msg.sender, _id, _amount, "");

        vaultOwnerInfo[msg.sender]=p;
    }

    function withdrawViron() public{
        if(vaultOwnerInfo[msg.sender].owner==address(0)) revert("You dont exist");
        Person storage p= vaultOwnerInfo[msg.sender];
        uint timeElapsedInDays= (block.timestamp-p.lastWithdrawal)/86400;
        uint vironToWithdraw= ((p.diamondVaultCount*diamondVaultRate)+(p.goldVaultCount)*goldVaultRate+(p.platinumVaultCount*platinumVaultRate))*timeElapsedInDays;
        viron.transfer(p.owner, vironToWithdraw);
        p.lastWithdrawal=block.timestamp; 
    }

    function transferVault(uint _id, uint _amount, address _to) public{
        safeTransferFrom(msg.sender, _to, _id, _amount, "");
        
    }

    function setPlatinumVault(uint _rate) external{
        platinumVaultRate=_rate;
    }

    function setGoldVaultRate(uint _rate) external {
        goldVaultRate=_rate;
    }

    function setDiamondVaultRate(uint _rate) external{
        diamondVaultRate=_rate;
    }
}