# Foundry Fundamentals

This is the third course on cyfrin updraft.

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
