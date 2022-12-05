// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract BlockitusMarketplace {
    uint8 constant public fee = 1;
    uint256 public idProposal;
    uint256 public accProfit;

    address public owner;

    IERC721 nft_collection;

    struct Proposal {
        address collection;
        address buyer;
        address seller;
        uint256 idNFT;
        uint256 price;
    }

    mapping (address => mapping (uint256 => uint256)) private _offers;
    
    mapping (uint256 => Proposal) private _proposalInfo;
    //all proposals that a buyer has sent
    mapping (address => uint256[]) private _proposalsRequests;
    mapping (uint256 => uint256) private _indexIdInBuyerLedger;
    
    //all Seller's proposals pending to accept
    mapping (address => uint256[]) private _proposalsPendingToAccept;
    mapping (uint256 => uint256) private _indexIdInSellerLedger;


    event Sell(address indexed seller, uint256 id, uint256 price);
    event Buy(address indexed buyer, address indexed seller, uint256 id, uint256 price);
    event ChangeOffer(uint256 id, uint256 new_price);
    event Gift(address indexed seller, address indexed beneficiary, uint256 id );
    event SendProposal(address indexed buyer, address indexed seller, uint256 price);

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
        uint256 profit = _compute_fee(price);
        require(msg.value > 0 && msg.value >= net , "Marketplace: Error in amount");
        require(msg.sender != seller, "Marketplace: You are the NFT's owner"); //msg.sender is the buyer
        nft_collection.safeTransferFrom(seller, msg.sender, id);
        delete _offers[collection][id];
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

    function change_price(address collection, uint256 id, uint256 price) public {
        nft_collection = IERC721(collection);
        address seller = nft_collection.ownerOf(id);
        require(msg.sender == seller, "Marketplace: You are not the owner.");
        uint256 old_price = _offers[collection][id];
        require(old_price != price && price > 0);
        _offers[collection][id] = price;
        emit ChangeOffer(id, price);
    }

    function gift(address collection, address beneficiary, uint256 id) public {
        nft_collection = IERC721(collection);
        address seller = nft_collection.ownerOf(id);
        require(msg.sender == seller, "Marketplace: You are not the owner.");
        nft_collection.safeTransferFrom(msg.sender, beneficiary, id);
        emit Gift(msg.sender, beneficiary, id);
    }

    function send_proposal(address collection, uint256 id) public payable {
        nft_collection = IERC721(collection);
        address seller = nft_collection.ownerOf(id);
        uint256 price = msg.value - _compute_fee(msg.value);
        accProfit += _compute_fee(msg.value);
        Proposal memory proposal = Proposal({
            collection: collection,
            buyer: msg.sender,
            seller: seller,
            idNFT: id,
            price: price
        });

        idProposal += 1;
        _proposalInfo[idProposal] = proposal;
        
        _proposalsRequests[msg.sender].push(idProposal);
        _indexIdInBuyerLedger[idProposal] = _proposalsRequests[msg.sender].length - 1;

        
        _proposalsPendingToAccept[seller].push(idProposal);
        _indexIdInSellerLedger[idProposal] = _proposalsPendingToAccept[seller].length - 1;
        emit SendProposal(msg.sender, seller, price);
    }


    function accept_proposal(uint256 proposalId ) public {
        address collection = _proposalInfo[proposalId].collection;
        address buyer = _proposalInfo[proposalId].buyer;
        address seller = _proposalInfo[proposalId].seller;
        uint256 id = _proposalInfo[proposalId].idNFT;
        uint256 price = _proposalInfo[proposalId].price;
        uint256 indexB = _indexIdInBuyerLedger[proposalId];
        uint256 indexS = _indexIdInSellerLedger[proposalId];
        nft_collection = IERC721(collection);
        require(msg.sender == nft_collection.ownerOf(id), "Marketplace: You are not the owner.");
        nft_collection.safeTransferFrom(msg.sender, buyer, id);
        delete _offers[collection][id];
        delete _proposalInfo[proposalId];
        delete _indexIdInBuyerLedger[proposalId];
        delete _indexIdInSellerLedger[proposalId];
        _swap(indexB, _proposalsRequests[buyer]);
        _swap(indexS, _proposalsPendingToAccept[seller]);
        emit Buy(buyer, seller, id, price);
        payable(seller).transfer(price);

    }   

    function cancel_proposal(uint256 proposalId) public {
        address collection = _proposalInfo[proposalId].collection;
        address buyer = _proposalInfo[proposalId].buyer;
        address seller = _proposalInfo[proposalId].seller;
        uint256 id = _proposalInfo[proposalId].idNFT;
        uint256 price = _proposalInfo[proposalId].price;
        uint256 indexB = _indexIdInBuyerLedger[proposalId];
        uint256 indexS = _indexIdInSellerLedger[proposalId];
        nft_collection = IERC721(collection);
        require(msg.sender == buyer, "Marketplace: You are not the proposal's owner.");
        delete _proposalInfo[proposalId];
        delete _indexIdInBuyerLedger[proposalId];
        delete _indexIdInSellerLedger[proposalId];
        _swap(indexB, _proposalsRequests[buyer]);
        _swap(indexS, _proposalsPendingToAccept[seller]);
        emit Buy(buyer, seller, id, price);
        payable(buyer).transfer(price);
        
    }
    
    function net_pay(address collection, uint256 id) public view returns (uint256) {
        uint256 price = _offers[collection][id];
        return price + _compute_fee(price);
    }

    function getPrice(address collection, uint256 id) external view returns (uint256) {
        return _offers[collection][id];
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
