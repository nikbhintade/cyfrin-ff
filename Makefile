-include .env

# :; is for putting full command on the same line as make command
# or you can just add `:` then enter and tab and then start writing new command 
build:; forge build

deploy-local:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url http://127.0.0.1:8545 --account AnvilTestAccount --broadcast

coverage:
	forge coverage --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage
