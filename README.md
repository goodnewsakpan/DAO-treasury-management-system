### DAO Treasury Management Smart Contract
This DAO Treasury Management Smart Contract is built for decentralized treasury management on the Stacks blockchain. This contract empowers members of a decentralized autonomous organization (DAO) to propose, vote on, and execute fund allocations from a shared treasury. Additionally, it offers functionality for staking treasury funds in external pools, as well as emergency features to handle DAO ownership transitions.

The contract is written in Clarity, Stacks' smart contract language, ensuring secure execution on the Stacks blockchain. It enables transparent governance over treasury funds, allowing members to collectively manage, allocate, and grow the DAO’s assets.

## Features
Key Functionalities:
- Member-Weighted Voting: Voting power is assigned based on each member's stake within the DAO.
Proposal Creation: DAO members can propose fund allocations, including title, description, recipient, and requested amount.
- Voting Mechanism: DAO members cast votes on proposals within a specified timeframe, recorded with member weights.
Fund Transfers: Proposals with majority approval are executed, transferring STX funds to the designated recipient.
- Treasury Staking: Treasury funds can be staked in external pools, allowing the DAO to generate returns on assets.
Ownership Controls: Ownership and member weights can be updated by the DAO owner to adapt to changes.

## Data Structures
Proposals:

Stores each proposal with:
Proposer: Address of the member who created the proposal.
Title: A brief, descriptive title.
Description: Detailed description of the proposal.
Amount: Requested STX amount for the proposal.
Recipient: Address to which funds are transferred if the proposal is accepted.
Start Block: Block number when the proposal was created, defining the voting period.
Votes: Counts for yes and no votes, weighted by members’ voting power.
Execution Status: Indicates if the proposal has been executed.
Votes:

Tracks each member’s voting status per proposal, preventing multiple votes.
Member Weights:

Assigns and stores voting weights for each DAO member.
## DAO Variables:

proposal-count: Tracks the total number of proposals.
dao-owner: Stores the address of the DAO owner, who has administrative privileges.
total-members: Counts the total number of DAO members.
Error Handling
The contract includes comprehensive error handling to prevent unauthorized access and ensure data integrity:

ERR-NOT-AUTHORIZED (100): Triggered if a non-authorized entity attempts a restricted action.
ERR-PROPOSAL-NOT-FOUND (101): Returned if a proposal with the specified ID does not exist.
ERR-INSUFFICIENT-FUNDS (102): Occurs when there are insufficient funds for transfers.
ERR-ALREADY-VOTED (103): Prevents a member from voting twice on the same proposal.
ERR-PROPOSAL-EXPIRED (104): Indicates that the voting period has ended.
ERR-INVALID-WEIGHT, ERR-INVALID-TITLE, ERR-INVALID-DESCRIPTION, ERR-INVALID-AMOUNT: Validate inputs to ensure proposal integrity.
ERR-ZERO-AMOUNT (112): Prevents zero-value fund transfers.
Functionality

##DAO Membership Management
Add Member: add-member enables the DAO owner to add a new member with a specified voting weight.
Update Member Weight: update-member-weight allows the DAO owner to modify a member's voting power.
Proposal Creation and Management
Create Proposal: create-proposal allows DAO members to submit new proposals for fund allocation.
Input validation ensures that the title and description are not empty, the requested amount is above a minimum threshold, and the recipient is valid.

## Voting System
Vote on Proposal: vote enables DAO members to cast votes on proposals. Voting power is based on each member's assigned weight.
Voting Period: Each proposal has a fixed voting period (VOTING_PERIOD), after which voting closes.
Proposal Execution
Execute Proposal: execute-proposal is used to transfer funds to a recipient if the proposal receives majority support (yes votes > no votes).
Execution checks that the voting period has not expired, verifies funds, and marks the proposal as executed.
Treasury Staking
Stake Treasury Funds: stake-treasury-funds allows the DAO owner to stake a specified amount in an external staking pool.
Unstake Treasury Funds: unstake-treasury-funds retrieves staked funds from an external pool.
The DAO must have sufficient balance in the treasury to carry out staking operations.
Emergency and Ownership Controls
Change Owner: change-owner allows the current owner to transfer ownership to a new address, ensuring DAO continuity in emergencies.

## Usage Guide
Setup DAO Members: The DAO owner registers members by calling add-member, setting their initial voting weight.
Submit Proposal: Members create proposals using create-proposal to request fund allocations for specific purposes.
Vote on Proposal: Members vote on proposals with vote, casting either yes or no votes.
Execute Proposal: Approved proposals can be executed using execute-proposal, transferring funds to the recipient.
Stake Funds: The DAO owner stakes treasury funds via stake-treasury-funds.
Unstake Funds: To retrieve staked funds, the owner calls unstake-treasury-funds.