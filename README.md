# x_x-contracts

Contract deployed at KT19xorVBYtEy5sofm6HTJsP219MtzpybEtu - Ithicanet

The storage is the contract contains 2 main components

| Component       | Type         | Description  |
| ------------- |:-------------:| -----:|
|   users    | Big_map(address, user_profile) | A profile contains details of which assets a user owns and how the asset is distributed amongst the beneficiaries of the user  |
|   trigger list   |   Big_map(timestamp, list(address))    |   Each timestamp is normalised to 0000 hours of the day. The list of addresses is a list of addresses for whom the switch is to be triggered on a certain timestamp. |

The smart contract has 3 entry points.

create user - 
This is used to create and update a user's profile. 
A user's profile contains details about the assets that the user owns and the distribution details of each asset.

update trigger - 
This is used to reset the dead man's switch by 6 months (1 day for test accounts)

run transfers - 
This is used to execute transfers to beneficiary accounts when the switch is triggered. This is triggered once everyday from a server.

The storage of the smart contract 
This can be called by anyone. The endpoint execution fails when the 

