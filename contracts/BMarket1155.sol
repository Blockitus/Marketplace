// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BMarket1155 is ERC1155, IERC721Receiver {
    uint8 constant public fee = 1;
    uint8 constant tokenAccount = 1;
    uint256 public accProfit;
    uint256 private _offerId;
    address public owner;

    IERC721 nft_collection;

    //message = struct Order {address seller, address collection, uint256 nftIdd, uint256 price}  
    mapping (uint256 => bytes) private _offers;

    event Sell(address indexed seller, uint256 id, uint256 price);
    event Buy(address indexed buyer, address indexed seller, uint256 id, uint256 price);

    constructor() ERC1155("") {
        owner = msg.sender;
    }     

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function sell(address collection, uint256 nftId, uint256 price) public {
        nft_collection = IERC721(collection);
        require(nft_collection.getApproved(nftId) == address(this), "Marketplace: You have not authorization to manage this item.`");
        require(price > 0, "Marketplace: The price should be greater than 0.");
        nft_collection.safeTransferFrom(msg.sender, address(this), nftId);
        bytes memory offer = abi.encode(msg.sender, collection, nftId, price);
        _offerId += 1;
        _offers[_offerId] = offer;
        _mint(msg.sender, tokenAccount , _offerId, "");
    }

    function cancelOffer(uint256 offerId) public {
        bytes memory encodedData = _offers[offerId];
        (address seller, address collection, uint256 nftId, ) = abi.decode(encodedData, (address, address, uint256, uint256));
        require(msg.sender == seller, "Marketplace you are not the offer's owner" );
        delete _offers[offerId];
        _burn(msg.sender, tokenAccount, offerId);
        nft_collection = IERC721(collection);
        nft_collection.safeTransferFrom(address(this), msg.sender, nftId);
    }

    function buy(uint256 offerId) public payable {
        bytes memory encodedData = _offers[offerId];
        (address seller, address collection, uint256 nftId, uint256 price) = abi.decode(encodedData, (address, address, uint256, uint256));
        require(msg.value >= price + _compute_fee(price), "Marketplace: You have not enough funds.");
        delete _offers[offerId];
        _burn(seller, tokenAccount, offerId);
        nft_collection = IERC721(collection);
        nft_collection.safeTransferFrom(address(this), msg.sender, nftId);
        uint256 remaining = msg.value - price + _compute_fee(price);
        accProfit += _compute_fee(price);
        payable(seller).transfer(price);
        if (remaining > 0) {
            payable(msg.sender).transfer(remaining);
        }
       
    }

    function change_price(uint256 offerId, uint256 price) public {
        bytes memory encodedData = _offers[offerId];
        (address seller, address collection, uint256 nftId, ) = abi.decode(encodedData, (address, address, uint256, uint256));
        require(msg.sender == seller, "Marketplace: You are not the offer's owner.");
        bytes memory offer = abi.encode(msg.sender, collection, nftId, price);
        _offers[_offerId] = offer;
    }

    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Notification: You are not the owner");
        require(accProfit > 0, "Marketplace: You do not have any profit to withdraw");
        require(amount <= accProfit, "Marketplace: You do not have that accumulated.");
        accProfit -= amount;
        payable(owner).transfer(amount);
    }

    function getOffer(uint256 offerId) external view returns(address, address, uint256, uint256) {
        bytes memory encodedData = _offers[offerId];
        (address seller, address collection, uint256 nftId, uint256 price) = abi.decode(encodedData, (address, address, uint256, uint256));
        return (seller, collection, nftId, price);
    }


    function _compute_fee(uint256 price) private pure returns (uint256) {
        return price * fee / 100;
    }


}