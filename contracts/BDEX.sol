// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BMarketExtended is ERC1155{
    uint8 constant public fee = 1;
    uint8 constant FT = 1;
    uint256 public accProfit;
    uint256 private _offerId;
    address public owner;

    IERC20 erc20;
    
    //message = struct Order {address seller, address collection, uint256 nftIdd, uint256 price}  
    mapping (uint256 => bytes) private _offers;

    event Sell(address indexed seller, address indexed ftLedger, uint256 amount, uint256 indexed price);
    event Buy(address indexed buyer, address indexed ftLedger, uint256 amount, uint256 indexed price);

    constructor() ERC1155("") {
        owner = msg.sender;
    }     

    function sell(address ftLedger, uint256 amount, uint256 price) public {
        erc20 = IERC20(ftLedger);
        require( erc20.allowance(msg.sender, address(this)) == amount, "Marketplace: You have not authorization to manage this item.`");
        require(price > 0, "Marketplace: The price should be greater than 0.");
        assert(erc20.transferFrom(msg.sender, address(this), amount));
        bytes memory offer = abi.encode(msg.sender, ftLedger, amount, price);
        _offerId += 1;
        _offers[_offerId] = offer;
        _mint(msg.sender, FT , _offerId, "");
        emit Sell(msg.sender, ftLedger, amount, price);
    }

    function cancelOffer(uint256 offerId) public {
        bytes memory encodedData = _offers[offerId];
        (address seller, address ftLedger, uint256 amount, ) = abi.decode(encodedData, (address, address, uint256, uint256));
        require(msg.sender == seller, "Marketplace you are not the offer's owner" );
        delete _offers[offerId];
        _burn(msg.sender, FT, offerId);
        erc20 = IERC20(ftLedger);
        assert(erc20.transfer(msg.sender, amount));
    }
 function buy(uint256 offerId) public payable {
        bytes memory encodedData = _offers[offerId];
        (address seller, address ftLedger, uint256 amount, uint256 price) = abi.decode(encodedData, (address, address, uint256, uint256));
        uint256 net = price + _compute_fee(price);
        require(msg.value >= net, "Marketplace: You have not enough funds.");
        delete _offers[offerId];
        _burn(seller, FT, offerId);
        uint256 remaining = msg.value - net;
        accProfit += _compute_fee(price);
        erc20 = IERC20(ftLedger);
        assert(erc20.transfer(msg.sender, amount));  
        payable(seller).transfer(price);
        if (remaining > 0) {
            payable(msg.sender).transfer(remaining);
        }
        emit Buy(msg.sender, ftLedger, amount, price);    
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
        (address seller, address ftLedger, uint256 amount, uint256 price) = abi.decode(encodedData, (address, address, uint256, uint256));
        return (seller, ftLedger, amount, price);
    }


    function _compute_fee(uint256 price) private pure returns (uint256) {
        return price * fee / 100;
    }


}