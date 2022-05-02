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
  trigger_time : nat; 
}

type storage = {
  users : (address, user_profile) big_map;
}

(*Params*)
type create_user_param = {
  user_profile : user_profile; 
}

type params = 
CreateUserParam of create_user_param 
| Test of create_user_param


let asset_distribution_sum (distribution : asset_distribution list) : nat = 
  let sum (acc, distribution : nat * asset_distribution) : nat =
    acc + distribution.percentage in 
  List.fold_left sum 0n distribution

let assert_asset_distribution_sum (assets : token_asset list) : unit = 
  let predicate = fun (asset: token_asset) -> 
    assert_with_error ((asset_distribution_sum asset.token_details.distribution) = 100n) "asset distribution sum error" in
  List.iter predicate assets
  
let create_user (p, storage : (create_user_param * storage)) : (operation list * storage) = 
  (*check if user exists already*)
  let user_address: address = Tezos.sender in
  let users: (address, user_profile) big_map = storage.users in
  let user_exists: bool = Big_map.mem (user_address) users in
  if user_exists then failwith("UserAlreadyExists")
  else
    let u : unit = assert_asset_distribution_sum p.user_profile.token_assets in
    let updated_users: (address, user_profile) big_map = 
      Big_map.update user_address (Some p.user_profile) users in 
    ([]: operation list), { storage with users = updated_users }

let main (param, s : params * storage): (operation list * storage) = 
  match param with 
  | CreateUserParam p -> create_user(p, s)
  | Test p -> create_user(p, s)


