#include "./interface.mligo"


let asset_distribution_sum (distribution : asset_distribution list) : nat = 
  let sum (acc, distribution : nat * asset_distribution) : nat =
    acc + distribution.percentage in 
  List.fold_left sum 0n distribution

let assert_asset_distribution_sum (assets : token_asset list) : unit = 
  let predicate = fun (asset: token_asset) -> 
    assert_with_error ((asset_distribution_sum asset.distribution) = 100n) "asset distribution sum error" in
  List.iter predicate assets
 

let create_user (p, storage : (create_user_param * storage)) : (operation list * storage) = 
  (*check if user exists already*)
  let user_address: address = Tezos.sender in
  let users: (address, user_profile) big_map = storage.users in
  let user_exists: bool = Big_map.mem (user_address) users in
  if user_exists then failwith("UserAlreadyExists")
  else
    let _u : unit = assert_asset_distribution_sum p.user_profile.token_assets in
    let updated_users: (address, user_profile) big_map = 
      Big_map.update user_address (Some p.user_profile) users in 

    (*check for time correctness, should divide 86400 *)
    
    let new_pending_triggers : (timestamp, address list) big_map = 
      match Big_map.find_opt p.user_profile.trigger_time storage.pending_triggers with 
        Some pending_trigger_list -> 
          let updated_pending_triggers : address list = user_address :: pending_trigger_list in
          Big_map.update (p.user_profile.trigger_time) (Some updated_pending_triggers) (storage.pending_triggers)
        | None -> 
          Big_map.update (p.user_profile.trigger_time) (Some [user_address]) (storage.pending_triggers)
    in
    ([]: operation list), { storage with users = updated_users; pending_triggers = new_pending_triggers }

let update_trigger_time (p, storage : (update_trigger_param * storage)) : (operation list * storage) = 
  let user_address: address = Tezos.sender in 
    let user_profile : user_profile = match Big_map.find_opt user_address storage.users with 
      Some user -> user
    | None -> (failwith "UserDoesNotExist" : user_profile)
    in
    let new_user_profile : user_profile = { user_profile with trigger_time = p }
    in 
    let updated_users: (address, user_profile) big_map = 
      Big_map.update user_address (Some new_user_profile) storage.users in 
    ([]: operation list), { storage with users = updated_users }




let add_to_op_list (op_list: operation list) (new_op : operation) : operation list = new_op :: op_list

(*converts address * token asset into  *)
let token_transactions (p : (address * token_asset)) : operation list = 
  let (user_address, asset) = p in
  let token_contract : transfer contract = match (Tezos.get_contract_opt asset.token_details.address: transfer contract option) with 
        Some contract -> contract
      | None -> (failwith "TokenContractNotFound": transfer contract)
      in 
  let distribution_to_transaction (distribution: asset_distribution) : operation = 
    let transfer_param : transfer = {
      from = user_address;
      to_ = distribution.beneficiary_address;
      value = (asset.amount * distribution.percentage) / 100n;
    } in
    Tezos.transaction transfer_param 0mutez token_contract
  in
  List.map distribution_to_transaction asset.distribution 

let get_per_asset_transactions (p : (address * token_asset list)) : (operation list) list = 
  let (user_address, assets) = p in 
  let predicate (asset: token_asset) = (user_address, asset) in
  let address_asset_pair_list = List.map predicate assets 
  in
  List.map token_transactions address_asset_pair_list 

let run_transfer_transactions (p, storage: (run_transfer_transaction_param * storage)) : (operation list * storage) = 
  let time_today : timestamp = Tezos.now in
  let today_trigger_address_list : address list = match Big_map.find_opt time_today storage.pending_triggers with
    Some today_trigger_list -> today_trigger_list 
  | None -> (failwith "NoTriggersToday": address list)
  in
  let address_to_asset_list_pair (user_address : address) : address * (token_asset list) = 
    match Big_map.find_opt user_address storage.users with 
      Some profile -> (user_address, profile.token_assets) 
    | None -> (failwith "BadAddress": address * token_asset list)
  in
  let address_assets_pair_list : (address * token_asset list) list = 
      List.map address_to_asset_list_pair today_trigger_address_list
  in 
  let transactions_list = List.map get_per_asset_transactions address_assets_pair_list 
  in
  let x : operation list list = match List.head_opt transactions_list with 
    Some p -> p
  | None -> []
  in
  (([]: operation list), { storage with users = storage.users })

let main (param, s : params * storage) : (operation list * storage) = 
  match param with 
  | CreateUserParam p -> create_user(p, s)
  | UpdateTriggerParam p -> update_trigger_time(p, s) 
  | RunTransferTransactionParam p -> run_transfer_transactions(p, s)
