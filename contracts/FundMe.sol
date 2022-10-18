// SPDX-License-Identifier: MIT
// pragma
pragma solidity ^0.8.8;
// imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
// error codes
error FundMe__NotOwner();

// interfaces - if we had
// libraries - if we had

// contracts

/**
 * @title contract for crowdfunding
 * @author Matthew Woodard
 * @notice to demo a sample funding contract
 * @dev this implements price feeds as our libraries
 */
contract FundMe {
    // type declarations
    using PriceConverter for uint256;

    // state variables
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10**18;

    AggregatorV3Interface public priceFeed;

    // events - if we had

    // modifiers

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // functions
    // functions order:
    // constructor
    // receive
    // fallback
    // external
    // public
    // internal
    // private
    // view / pure

    // constructor
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // receive
    receive() external payable {
        fund();
    }

    // fallback

    fallback() external payable {
        fund();
    }

    /**

 * @notice this function funds this contract
 * @dev this implements price feeds as our libraries
 */
    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }
}
