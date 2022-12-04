// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/interfaces/IERC721.sol";


contract BlockitusMarketplace {
    //uint8 constant fee = 1;
    address public owner;


    event PutOffer(uint256 id, address indexed seller, uint256 price);
    event GetOffer(uint256 id , address indexed buyer, uint256 price);

    IERC721 nft_collection;

    mapping (address => mapping (uint256 => uint256)) prices;

    constructor () {
        owner = msg.sender;
    }

    function sell(address collection, uint256 id, uint256 price) public {
        //approve from web3 first at all.
        require(price > 0, "Notifcation: The price should be greater than 0.");
        prices[collection][id] = price;
        emit PutOffer(id, msg.sender, price);
        
    }


    function buy(address collection, uint256 id) public payable  {
        nft_collection = IERC721(collection);
        require(msg.value > 0, "Notification: Error in amount");
        require(msg.value >= prices[collection][id], "Notification: You need to paid the correct price");
        address _owner = nft_collection.ownerOf(id);
        nft_collection.safeTransferFrom(_owner, msg.sender, id);
        delete prices[collection][id];
        payable(_owner).transfer(msg.value);
        emit GetOffer(id, msg.sender, prices[collection][id]);
    }

    function withdraw() public {
        require(msg.sender == owner, "Notification: You are not the owner");
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() external view returns (uint256) {
        return  address(this).balance;
    }

}
