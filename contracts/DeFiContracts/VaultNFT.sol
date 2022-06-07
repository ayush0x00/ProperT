// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract VaultNFT is ERC1155{
    address owner;
    uint platinumVaultRate=20;
    uint goldVaultRate=25;
    uint diamondVaultRate=30;

    constructor() ERC1155("TokenURI string"){
        owner=msg.sender;
    }

    function mintVault(uint _id,uint _amount) public{ //takes a vault id and mints it by amount
        _mint(msg.sender, _id, _amount, "");
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