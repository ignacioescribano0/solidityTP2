****************************************************Auction Contract Explanation*********************************************

This document provides an overview of the smart contract, including its key variables, structs, events, modifiers, constructor, and functions. 

1. Structs

**Bid

Description: Represents a single bid placed in the auction.

**Fields:

address bidder: Ethereum address of the user placing the bid.

uint256 amount: Amount of Wei (ETH) bid by the user.

**MyBids

Description: Tracks the bidding history for each participant.

**Fields:

uint256 last                                         The amount of the most recent bid placed by the user.

uint256 accumulated                                  Total amount of Wei the user has sent to the contract so far.

2. State Variables

Bid[] public bids                                    Dynamic array that stores every bid in chronological order.

mapping(address => MyBids) public myBids             Associates each bidder's address with their MyBids record, allowing quick lookup of their last bid and total contributions.

uint256 public endDate                               timestamp indicating when the auction ends.

uint256 public initialValue                          Minimum starting bid in Wei (initialized to 1 ETH).

address public owner                                 Address of the auction owner (contract deployer) who has special privileges.

3. Events

event NewOffer(address bidder, uint256 amount)        Emitted whenever a new bid is successfully placed.

event AuctionEnded()                                  Signal that the auction has finished 

event AuctionStarted()                                Signal that the auction has started


4. Modifiers

modifier whenNotActive

Ensures the auction is over).

modifier whenActive

Ensures the auction is running).

modifier onlyOwner

Restricts function usage to the owner address.

5. Constructor

Initializes the auction with a short default duration, sets the starting bid to 1 ETH, records the deployer as the owner, and emits AuctionStarted.

6. Functions

6.1 function bid() external payable whenActive

Place a new bid by sending Ether. Require the new bid to exceed the previous by at least 5%. If the bid occurs within 10 minutes of endDate, extend endDate by 10 minutes.
Append the bid to the bids array and emit NewOffer.

6.2 function showWinner() view external returns (address)

Returns the address of the highest bidder.

6.3 function showBids() view external returns (Bid[] memory)

Provides the full list of bids.

6.4 function retDeposit() external whenNotActive onlyOwner

Refunds 98% of each participant's contributions (excluding the winner), then transfers remaining balance (fees + winner bid) to the owner. Emits AuctionEnded.

6.5 function partialRefund() external whenActive

Allows bidders to withdraw all but their most recent bid while the auction is still running, updating their accumulated total accordingly.



