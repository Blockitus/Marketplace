// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract BlockitusMarketplace {
    uint8 constant public fee = 1;
    uint256 public counter;
    uint256 public accProfit;

    address public owner;

    IERC721 nft_collection;

    struct Offer {
        address collection;
        uint256 nftId;
    }

    struct Proposal {
        address collection;
        address buyer;
        address seller;
        uint256 idNFT;
        uint256 price;
    }

    uint256[] private _totalOffers;
    
    mapping (uint256 => Offer) private _offers;
    mapping (uint256 => uint256) private _prices;
    mapping (uint256 => address) private _owners;
    mapping (address => uint256) private _offersQty;
    mapping (address => mapping(uint256 => uint256)) private _offerIndexById;

    event Sell(address indexed seller, uint256 id, uint256 price);
    event Buy(address indexed buyer, address indexed seller, uint256 id, uint256 price);
    event ChangeOffer(uint256 id, uint256 new_price);
    event Gift(address indexed seller, address indexed beneficiary, uint256 id );
    event SendProposal(address indexed buyer, address indexed seller, uint256 price);

    constructor () {
        owner = msg.sender;
    }

    function sell(address collection, uint256 nftId, uint256 price) public {
        //owner should have to approve the contract before call this function
        nft_collection = IERC721(collection);
        require(nft_collection.ownerOf(nftId) == msg.sender, "Marketplace: You are not the NFT's owner");
        require(price > 0, "Marketplace: The price should be greater than 0.");
        uint256 id = counter += 1;
        _totalOffers.push(id);
        _offers[id] = Offer(collection, nftId);
        _prices[id] = price;
        _owners[id] = msg.sender;
        _offersQty[msg.sender] += 1;
        _offerIndexById[msg.sender][id] = _totalOffers.length - 1;
        assert(nft_collection.safeTransferFrom(msg.seder, address(this), nftId));
        emit Sell(msg.sender, id,  price);
        
    }

    function cancel_offer(uint256 id) public {
        require(msg.sender == _owners[id], "Marketplace: You are not the offer's owner.");
        nft_collection = IERC721(_offers[id].collection);
        uint256 nftId = _offers[id].nftId; 
        _delete_offer(id);
        assert(nft_collection.safeTransferFrom(address(this), msg.sender, nftId));
    }


    function buy(uint256 id) public payable  {
        nft_collection = IERC721(_offers[id].collection); 
        uint256 nftId = _offers[id].nftId;
        uint256 net = net_pay(id);
        uint256 remaining = msg.value - net;
        uint256 price = _prices[id];
        uint256 profit = _compute_fee(price);
        uint256 seller = _owners[id];
        uint256 index = _offerIndexById[seller][id];
        require(index <= _offers.length - 1, "Marketplace: Offer does not exist.");
        require(msg.value >= net , "Marketplace: Error in amount");
        _delete_offer(id);
        assert(nft_collection.safeTransferFrom(address(this), msg.sender, nftId));
        payable(seller).transfer(price);
        if (remaining > 0) {
            payable(msg.sender).transfer(remaining);
        }
        accProfit += profit;
        emit Buy(msg.sender, seller, id, price);
    }


    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Notification: You are not the owner");
        require(accProfit > 0, "Marketplace: You do not have any profit to withdraw");
        require(amount <= accProfit, "Marketplace: You do not have that accumulated.");
        accProfit -= amount;
        payable(owner).transfer(amount);
    }

    function change_price(uint256 id, uint256 price) public {
        nft_collection = IERC721(_offers[id].collection); 
        require(msg.sender == _owners[id], "Marketplace: You are not the owner.");
        uint256 old_price = _prices[id];
        require(old_price != price && price > 0);
        _prices[id] = price;
        emit ChangeOffer(id, price);
    }

    function gift(address beneficiary, uint256 id) public {
        nft_collection = IERC721(_offers[id].collection); 
        require(msg.sender == _owners[id], "Marketplace: You are not the owner.");
        assert(nft_collection.safeTransferFrom(address(this), beneficiary, id));
        emit Gift(msg.sender, beneficiary, id);
    }
    
    function net_pay(uint256 id) public view returns (uint256) {
        return _prices[id] + _compute_fee(_prices[id]);
    }

    function getPrice(address collection, uint256 id) external view returns (uint256) {
        return _offers[collection][id];
    }

    function _delete_offer(uint256 id) private {
        uint256 seller = _owners[id];
        uint256 index = _offerIndexById[seller][id];
        _swap(index, _totalOffers);
        delete _offers[id];
        delete _prices[id];
        delete _owners[id];
        delete _offerIndexById[seller][id];
        _offersQty[seller] -= 1;
    }

    function _swap(uint256 index, uint256[] storage array) private {
       uint256 le = array.length - 1;
       array[index] = array[le];
       array.pop();
    }

    function _compute_fee(uint256 price) private pure returns (uint256) {
        return price * fee / 100;
    }

}
