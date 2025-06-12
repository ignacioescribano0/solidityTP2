
// SPDX-License-Identifier: MIT
pragma solidity  0.8.30;

// Auction contract
contract Subasta {
    // Represents a single bid
    struct Bid
    {
        address bidder;  // Address of the bidder
        uint256 amount;  // Amount they bid
    }
    // Tracks the last and total amount bid by each participant
    struct MyBids
    {
        uint256 last;                 // The last bid amount placed
        uint256 accumulated;          // Total amount sent by the bidder
    }
    
    Bid[] public bids;  // List of all bids placed in the auction

    mapping(address => MyBids) public myBids;   // Maps addresses to their bidding history
    uint256 public endDate;                    // Timestamp for when the auction ends
    uint256 public initialValue;              // Minimum initial bid value
    address public owner;                    // Owner
    
    // Events to log auction activity
    event NewOffer(address bider, uint256 amount);
    event AuctionEnded();
    event AuctionStarted();

    // Constructor initializes the auction
    constructor()
    {
        endDate=block.timestamp + 7 days ;        // Ends in 7 days
        initialValue = 1 ether;                    
        owner = msg.sender;                      // The contract creator is the auction owner
        emit AuctionStarted();
    }
    // Modifier to restrict actions when auction is inactive
    modifier whenNotActive
    {
        require(block.timestamp > endDate, "Auction Running");
        _;
    }
    // Modifier to restrict actions when auction is active
    modifier whenActive
    {
        require(block.timestamp < endDate, "Auction not Running");
        _;
    }
    // Modifier to restrict certain actions to the owner only
    modifier onlyOwner
    {
        require(owner==msg.sender,"Owner only");
        _;
    }

    // Function to place a new bid
    function bid() external payable whenActive
    {
        uint256 bidQuantity = bids.length;
        // Determine the minimum value required to outbid the previous one
        uint256 minValue = bidQuantity ==0? initialValue : bids[bidQuantity-1].amount;
        // Require a 5% increase over the previous bid
        require ((minValue*105/100) < msg.value, "Insuficient funds");
        // Extend the auction by 10 minutes if bid is near the end
        if ((block.timestamp +10 minutes) > endDate){
            endDate += 10 minutes;
        }
        // Record the bidder's last and total bid amounts
        myBids[msg.sender].last = msg.value;
        myBids[msg.sender].accumulated += msg.value;
        // Save the bid
        bids.push(Bid(msg.sender,msg.value));
        // Emit event for the new bid
        emit NewOffer(msg.sender,msg.value);

    }
    // View the winning bidder (last one in the list)
    function showWinner() view external returns(address)
    {
            uint256 bidQuantity = bids.length;
            return bids[bidQuantity-1].bidder;
    }

    // Return all bids placed
    function showBids() view external returns(Bid[] memory)
    {
            return bids;

    }
    // Refund deposits to all bidders 
    function retDeposit() external whenNotActive onlyOwner
    {
            uint256 bidQuantity = bids.length;
            uint256 value;
            address payable to;

            // Obtener al ganador (último postor)
            address winner = bids[bidQuantity - 1].bidder;

            for (uint256 i =0;i<bidQuantity;i++)
            {
                to = payable(bids[i].bidder);
                // Saltar al ganador: no se le devuelve nada
                if (to == winner) {
                    continue;
                }
                value = myBids[to].accumulated;
                value = value*98/100;
                if (value > 0) {
                    myBids[to].accumulated = 0;// Clear the record to prevent double refund
                    to.transfer(value);  
                }
            }
            // Send remaining balance  to the owner
            value = address(this).balance;
            to = payable(msg.sender);
            to.transfer(value);
            emit AuctionEnded();
    }
    

    // Allow a user to withdraw everything except their last bid while the auction is still active
    function partialRefund() external whenActive
    {
        uint256 value = myBids[msg.sender].accumulated -myBids[msg.sender].last;
        // Reset accumulated to only last bid
        myBids[msg.sender].accumulated = myBids[msg.sender].last;
        // Refund the difference
        address payable to = payable (msg.sender);
        to.transfer(value);

    }
}