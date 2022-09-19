# Proposal Details 
See [this doc](https://docs.google.com/document/d/1Qbx6z1-rmatgQMNHhFm8kgpAWxzEHtpYzu_Z-MzLK7w/edit) for the details on the project.
See [this doc](https://governance.aave.com/t/arc-whitelist-balancer-s-liquidity-mining-claim/9724) with the Aave proposal
See this doc (TBD) with the Balancer proposal.

TL;DR
- Balancer's contract has accrued LM rewards in stkAave on their stables (aUSDC, aDAI, aUSDT)
- Balancer cannot claim these from this contract, and needs to do so from another contract that calls the claimOnBehalfOf method
- In order for that to happen, Aave needs to whitelist this contract once deployed to claim on behalf of it
- This contract's payload function will be executed by Balancer's multisig 
- The deployer doesn't matter

# To build and test 
1) `cp .env.example .env`
2) copy and paste your node URL for ETH Mainnet into the .env file
3) `forge install`
4) `forge remappings`
5) `source .env`
6) `forge test -vvvv`