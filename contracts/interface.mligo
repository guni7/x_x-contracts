type asset_distribution = 
{
  beneficiary_address : address;
  percentage : nat;
}

type token_details = 
{
  token_type : string;
  is_fungible : bool;
  address : address;
  decimals : nat;
}

type token_asset = 
{
  asset_id : string;
  token_details : token_details;
  amount : nat ;
  distribution : asset_distribution list;
  uncapped : bool; 
}

type user_profile = 
{
  token_assets : token_asset list;
  trigger_time : timestamp; 
}

type storage = {
  users : (address, user_profile) big_map;
  pending_triggers : (timestamp, address list) big_map;
  admin_address : address;
}

(*Params*)
type create_user_param = {
  user_profile : user_profile; 
}
type update_trigger_param = timestamp

type run_transfer_transaction_param = unit

type params = 
CreateUserParam of create_user_param 
| UpdateTriggerParam of update_trigger_param
| RunTransferTransactionParam of run_transfer_transaction_param


type transfer =
[@layout:comb] {
   from : address;
   [@annot:to]to_: address;
   value: nat;
}
