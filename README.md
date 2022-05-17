# x_x-contracts

The smart contract has 3 entrypoints.

create user - This is used to create and update a user's profile. A user's profile contains details about the assets that the user owns and their distribution details.

update trigger - This is used to reset the dead man's switch by 6 months (1 day for test accounts)

run transfers - This is used to execute transfers to beneficiary accounts when the switch is triggered. This is triggered once everyday from a server.

