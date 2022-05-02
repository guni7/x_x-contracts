type asset_distribution = 
{
  beneficiary_address : address;
  percentage : nat;
}

type token_details = 
{
  token_type : string;
  address : string;
  decimals : nat;
  distribution : asset_distribution list;
}

type token_asset = 
{
  asset_id : string;
  token_details : token_details;
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
}

(*Params*)
type create_user_param = {
  user_profile : user_profile; 
}

type params = 
CreateUserParam of create_user_param 
| Test of create_user_param

