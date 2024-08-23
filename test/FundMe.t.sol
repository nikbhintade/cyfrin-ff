// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; // putting contract in golbal variable

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 100;

    function setUp() external {
        // us -> FundMeTest -> FundMe
        // test contract is deploying the contract that is being tested
        // so if we are setting owner for the contract, we won't be the owner
        // instead the test contract will be owner of contract that is being tested.abi

        // probably reason is to understand from each action from the point of deployer
        // and deployer in this case is this test contract.
        // NOT VERY INTUITIVE -> maybe this reasoning makes sense to maintainers
        // I work on this maybe I will understand why they did that this way.

        // old way confusing
        // fundMe = new FundMe(0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165);

        // deploy contracts with script to use in test
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // also changes how owner is set in test where we are testing owner
        // with script the owner of the deployed contract will be the wallet
        // that is deploying the contract

        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsTwo() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        // next step after expectRevert should revert, if not
        // then test will fail.

        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        // when this modifier is added to a test it setup initial condition for
        // that test and if you have to set these conditions multiple times
        // then this abstraction of that piece will be very useful for
        // keeping test clean and readable.
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // note anything related to vm that comes after vm.expectRevert
        // will be ignored so this we have written this test correctly then
        // the test should pass without any issue.
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        vm.assertEq(endingFundMeBalance, 0);
        vm.assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunder() public funded {
        // Arrange

        // here we are using uint160 as that number will be used
        // to create address from it.
        // and we can't use uin256 to create address
        // reason: uin160 has same bytes as address and that why
        // we need to use uint160 type if you want to cast it to address
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE); // (address, balance)
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // ACT
        uint256 gasStart = gasleft();
        console.log("gas left at start: ", gasStart);

        // vm.prank(fundMe.getOwner());
        // fundMe.withdraw();
        vm.txGasPrice(GAS_PRICE);
        // following approach is alternative to above which let's tests
        // know all the actions between start and stop are taken by
        // address given in startPrank as an argument.
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        console.log("Gas left at the end: ", gasEnd);
        // ASSERT

        vm.assertEq(address(fundMe).balance, 0);
        vm.assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFunderCheaper() public funded {
        // Arrange

        // here we are using uint160 as that number will be used
        // to create address from it.
        // and we can't use uin256 to create address
        // reason: uin160 has same bytes as address and that why
        // we need to use uint160 type if you want to cast it to address
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE); // (address, balance)
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // ACT
        uint256 gasStart = gasleft();
        console.log("gas left at start: ", gasStart);

        // vm.prank(fundMe.getOwner());
        // fundMe.withdraw();
        vm.txGasPrice(GAS_PRICE);
        // following approach is alternative to above which let's tests
        // know all the actions between start and stop are taken by
        // address given in startPrank as an argument.
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        console.log("Gas left at the end: ", gasEnd);
        // ASSERT

        vm.assertEq(address(fundMe).balance, 0);
        vm.assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }
}
