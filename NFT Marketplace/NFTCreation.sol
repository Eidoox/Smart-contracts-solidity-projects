// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTCreation is ERC721URIStorage {
    address nftmarketplace_contractaddress;
    mapping (address => uint256 [])  OwnedNFTS;
    uint256  currentNFTid;
 
    constructor (address marketplace_contractaddress) ERC721 ("NFT Marketplace DAPP","NMD"){
        nftmarketplace_contractaddress = marketplace_contractaddress;
        
    }

    function createNFT (string memory tokenuri) public returns (uint256){
        currentNFTid ++;
        _safeMint(msg.sender, currentNFTid);
        _setTokenURI(currentNFTid, tokenuri);
        setApprovalForAll(nftmarketplace_contractaddress , true);
        OwnedNFTS [msg.sender].push(currentNFTid);
        return currentNFTid;
    }

    function getmynfts () public view returns (uint256 [] memory){
        
        return OwnedNFTS[msg.sender];

    }
    function getcurrentnftid () public view returns (uint256){
        
        return currentNFTid;

    }

}
