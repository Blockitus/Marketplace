// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract BlockitusMarketplace {
    uint8 constant fee = 1;
    address public owner;


    event Sell(address indexed seller, uint256 id, uint256 price);
    event Buy(address indexed buyer, address indexed seller, uint256 id, uint256 price);

    IERC721 nft_collection;

    mapping (address => mapping (uint256 => uint256)) private _offers;

    constructor () {
        owner = msg.sender;
    }

    function sell(address collection, uint256 id, uint256 price) public {
        //owner should have to approve the contract before call this function
        nft_collection = IERC721(collection);
        require(nft_collection.ownerOf(id) == msg.sender || nft_collection.getApproved(id) == msg.sender, "Marketplace: You have not permits over this item");
        require(price > 0, "Marketplace: The price should be greater than 0.");
        _offers[collection][id] = price;
        emit Sell(msg.sender, id,  price);
        
    }


    function buy(address collection, uint256 id) public payable  {
        nft_collection = IERC721(collection); 
        address seller = nft_collection.ownerOf(id);
        uint256 price = _offers[collection][id];
        uint256 net = net_pay(collection, id);
        uint256 remaining = msg.value - net;
        require(msg.value > 0 && msg.value >= net , "Marketplace: Error in amount");
        require(msg.sender != seller, "Marketplace: You are the NFT's owner"); //msg.sender is the buyer
        nft_collection.safeTransferFrom(seller, msg.sender, id);
        delete _offers[collection][id];
        payable(seller).transfer(price);
        if (remaining > 0) {
            payable(msg.sender).transfer(remaining);
        }
        emit Buy(msg.sender, seller, id, price);
    }


    function withdraw() public {
        require(msg.sender == owner, "Notification: You are not the owner");
        payable(owner).transfer(address(this).balance);
    }

    function net_pay(address collection, uint256 id) public view returns (uint256) {
        uint256 price = _offers[collection][id];
        return price + compute_fee(price);
    }

    function getPrice(address collection, uint256 id) external view returns (uint256) {
        return _offers[collection][id];
    }

    function compute_fee(uint256 price) private pure returns (uint256) {
        return price * fee / 100;
    }

}
