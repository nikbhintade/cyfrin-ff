# Foundry Fundamentals

This is the third course on Cyfrin Updraft. These notes focus on the course itself, but one of my key motivations for going through it is to learn from how Cyfrin has structured their courses. This will help me in writing and planning my own tutorial series.

## Section 1: Foundry Simple Storage

### Notes:

-   Compiling or building project: `forge build` or `forge compile`

-   `forge` commands can be interactive with `--interactive` flag, this will ask for things it will need to complete the command

-   Starting local network can be done with `anvil` which comes with `foundry`

-   To deploy contract we need to run following command: `forge create <CONTRACT> --interactive`. This will ask for private key with which forge will deploy the contract. Before this I have my `anvil` server running so `forge` is deploying it on the local network which is anvil server.

---

-   Foundry scripts

    -   These scripts are stored in the script folder.

    -   Naming convention for these scripts in foundry is that all script files end with `<FILENAME>.s.sol`

    -   To run script you need to run following command: `forge script <SCRIPT_FILE_PATH>`.

    -   Issue with above command is that it runs script on temporary anvil chain so even if you have anvil server running above command doesn't interact with it. You explicitly need to specify the RPC url in the command. Here is modified command: `forge script script/SimpleStorage.s.sol:DeploySimpleStorage --fork-url http://127.0.0.1:8545` or `forge script script/SimpleStorage.s.sol --rpc-url http://127.0.0.1:8545`

    -   Above command only simulates the transaction and doesn't actually deploy it on network.

    -   This means it gives you estimation of gas, gas price and total fee that deployment of contract will take.

    -   To actually deploy the contract, you need to add `--broadcast` flag along with private key of wallet with which you are going to deploy.

    -   Complete command: `forge script script/SimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key <PRIVATE_KEY>`

        -   With `--interactives`, we can avoid adding private key in command but haven't figured it out yet. Read this: [improvement: cast wallet import / --account option by rplusq · Pull Request #5551 · foundry-rs/foundry · GitHub](https://github.com/foundry-rs/foundry/pull/5551)

        -   I figured out how to add private key in keystore and use it with script command, here is the comand I used: `forge script script/SimpleStorage.s.sol:DeploySimpleStorage --rpc-url http://127.0.0.1:8545 --broadcast --account AnvilTestAccount --sender <WALLET_ADDRESS>`

        -   Some other command, create keystore with cast: `cast wallet import <WALLET_NAME> --interactive`. This will ask for private key and password in next prompts. Get list of wallet stored: `cast wallet list`

        -   I don't understand why it is giving me error if I don't use `--sender` flag. Explanations on google search are vague. This is irritating and I still have to do it.

        -   [ ] TODO: ERC-2335 and WTF that is.

---

-   Writing to contract with `cast`, command: `cast send 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "store(uint256)" 123 --rpc-url http://127.0.0.1:8545 --account AnvilTestAccount`. Don't need `--sender` here.

-   Reading from contract with `cast`, command: `cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "retrieve()" --rpc-url http://127.0.0.1:8545`. This is going to return hex, value which can be converted to decimal with `cast --to-dec <HEX_VALUE>`

-   For consistent formatting `forge` has in-built funtionality: `forge fmt`

---

### Foundry ZKsync

> Just took notes, instead of following the course as I don't want.

zksync and vanilla evm are same at high level but at low level there are some differences that's why matter labs has created [foundry-zksync](https://github.com/matter-labs/foundry-zksync).

My ubuntu 20.04 system doesn't satisfy the requirements that foundry-zksync need. I don't want to update whole system just to deploy on zksync testnet instead I will just stick with some other testnet like Eth, Base or Arbritrum.

Issue with `foundryup-zksync` is that `libc6` version that is on machine is less than what it needs and just updating with `apt` is not working due to APT sources not having latest version of `libc6` on it.

> This is my understanding and terms in the explanation or the whole explanation might be wrong.

-   [ ] Read about Transaction Types in details - I do understand EIP-1559 but no what are other types.

## Section 2 - FundMe

Notes:

-   Command to see foundry remappings: `forge remappings`. Read more about remappings [here](https://book.getfoundry.sh/projects/dependencies).

-   Naming Convention for test files is `<FILE_NAME>.t.sol`

Notes on Tests:

-   Ownership of deployed contract goes to contract i.e. `TestFundMe.t.sol` and not wallet that is deploying it. This is bit confusing. I don't understand the reasoning behind it.

    -   Ex. we write test -> that test deploys contract. This will set owner of contract to test contract and not the wallet that is deploying it. This is kind of like factory pattern without option to change the owner.

    -   So when testing for owner, we need to compare address of owner to test contract and not the test wallet.

-   types of test:

    -   Unit: Testing a specific part of our code

    -   Integration: Testing how our code works with other parts of our code

    -   Forked: Testing our code on a simulated real environment

    -   Staged: Testing our code in real environment that is not prod

-   Fork testing is just fetching state of certain thing from chain and then running test against those things.

    -   For current contract to demonstrate the fork testing, I tested if chainlink pricefeed is returning correct version as I expected which is 4.

        ```solidity
        // getVersion Function
        ```

            function getVersion() public view returns (uint256) {
                AggregatorV3Interface priceFeed = AggregatorV3Interface(
                    0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165
                );
                return priceFeed.version();
            }

        ````
        ```solidity
        // function from FundMe.t.sol
        ````

            function testPriceFeedVersion() public view {
                assertEq(fundMe.getVersion(), 4);
            }

        ```

        ```

-   Now that this was added command to test this function was as follows:

    ```bash
    forge test --mt testPriceFeedVersion -vvvv --fork-url $ARB_SEPOLIA_RPC_URL
    ```

-   `--mt` flag is to filter particular tests from list of test. I wanted to run `testPriceFeedVersion` so I passed that

-   `-vvvv` is to see trace and check where things are failing.

-   `--fork-url` or `--rpc-url` is to pass the RPC url of the network. Also, `$ARB_SEPOLIA_RPC_URL` is added to the terminal so command knows it's value. To add it, I can run `source .env` and all variables from that file will be added to terminal for my use in command.

-   In course, there was a refactor which was to pass address of price feed through construtor and then using script to deploy contract for test.

    -   First one I understood as it was simple.

    -   Second one changed how tests where working. Before this if you deployed contract in `setUp` function of the test it was setting test contract address as the owner of the `fundMe` contract that was being deployed to test. Now when using script contract to deploy contract for the test **that is not the case**.

        ```solidity
        // modified code in test.

        // SPDX-License-Identifier: MIT
        pragma solidity 0.8.19;

        import {Test, console} from "forge-std/Test.sol";
        import {FundMe} from "../src/FundMe.sol";
        import {DeployFundMe} from "../script/DeployFundMe.s.sol";

        contract FundMeTest is Test {
            FundMe fundMe; // putting contract in golbal variable

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
            }
        }
        ```

-   This is change makes more sense in context of testing. Also, if there are any deployment changes then all those will remain same in test and prod environment.

-   Command to run all tests on forked network:

    ```bash
    forge test --fork-url $ARB_SEPOLIA_RPC_URL -vvvvv
    ```

-   Setting tests with modifier is a great idea, as modifier runs before executing the function it also works as setup for tests.

    ```solidity
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
    ```

-   alternative to prank + deal = hoax; first 2 are cheatcode and later is from foundry standard library.

    ```solidity
                hoax(address(i), SEND_VALUE); // (address, balance)
    ```

-   Default gas price on Anvil is 0 but we can change it with `vm.txGasPrice(GAS_PRICE)` if you want to test all these things in real world scenario.

    -   [ ] Test set gas price and the test fail

        My current issue is even after setting gas price transaction is not failing even if you don't calculate the difference of balance due to gas consumption. Find out why it is not failing even though it should.

        ```solidity
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
        ```

-   Getting snapshot with `forge`, command: `forge snapshot --mt testWithdrawFromMultipleFunder`

    -   This generates `.gas-snapshot` file where it shows how much gas a function consumes.

-   Storage Optimization:

    -   State variables are stored in subsequent spots. Each storage slot is 32 bytes long.

    -   In storage slot of array, only it's length is stored. Acutal elements are stored somewhere else - details about how array is stored are in solidity docs so you can read it.

    -   Mappings storage slot is left empty - read reasoning in solidity docs

    -   Constant variables are stored in contract's bytecode so they don't need storage slot.

    -   Ways to see storage layout in foundry;

        -   `forge inspect FundMe storageLayout`

        -   `cast storage <CONTRACT_ADDRESS> <SLOT_NUMBER>`

-   Structuring `tests` folder:

    -   Integration: functions called with script and testing on different parameters

    -   Mocks: mock contracts will be included in that.

    -   unit: each pieces will code tested separately.

-   You can't do prank on if you're using `vm.startBroadcast`:

    -   ```solidity
        contract FundFundMe is Script {
            uint256 SEND_VALUE = 0.1 ether;

            function fundFundMe(address mostRecentlyDeployed) payable public {
                FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
            }

            function run() external {
                address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
                    "FundMe",
                    block.chainid
                );
                vm.startBroadcast();
                fundFundMe(mostRecentlyDeployed);
                vm.stopBroadcast();
                console.log("Funded FundMe with %s", SEND_VALUE);
            }
        }
        ```

    -   That's why I have added broadcast in run function as it will work well when doing things on live network but when we access this script in integration test it will complete

    -   With `foundry coverage`, it generates `lcov.info` file which gives many details about coverage but it doesn't generate html project like I was used to but from generated file, we can generated html file to visually see coverage.

        -   command: `forge coverage --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage`

        -   Make sure `lcov` is installed with `sudo apt install lcov`
