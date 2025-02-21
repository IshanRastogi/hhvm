(*
 * Copyright (c) 2015, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the "hack" directory of this source tree.
 *
 *)

module type S = WrappedMap_sig.S

module Make (Ord : Map.OrderedType) : S with type key = Ord.t = struct
  include Map.Make (Ord)

  let union ?combine x y =
    let combine =
      match combine with
      | None -> (fun _ fst _ -> Some fst)
      | Some f -> f
    in
    union combine x y

  let merge_env env s1 s2 ~combine =
    let (env, map) =
      Common.List.fold_left_env
        env
        ~init:empty
        ~f:(fun env map (key, v2) ->
          let v1opt = find_opt key s1 in
          let (env, vopt) = combine env key v1opt (Some v2) in
          let map =
            match vopt with
            | None -> map
            | Some v -> add key v map
          in
          (env, map))
        (bindings s2)
    in
    Common.List.fold_left_env
      env
      ~init:map
      ~f:(fun env map (key, v1) ->
        let v2opt = find_opt key s2 in
        match v2opt with
        | None ->
          let (env, vopt) = combine env key (Some v1) None in
          let map =
            match vopt with
            | None -> map
            | Some v -> add key v map
          in
          (env, map)
        | Some _ -> (env, map))
      (bindings s1)

  let union_env env s1 s2 ~combine =
    let f env key o1 o2 =
      match (o1, o2) with
      | (None, None) -> (env, None)
      | (Some v, None)
      | (None, Some v) ->
        (env, Some v)
      | (Some v1, Some v2) -> combine env key v1 v2
    in
    merge_env env s1 s2 ~combine:f

  let keys m = fold (fun k _ acc -> k :: acc) m []

  let ordered_keys m = Base.List.map ~f:fst (bindings m)

  let values m = fold (fun _ v acc -> v :: acc) m []

  let fold_env env f m init =
    fold (fun key v (env, acc) -> f env key v acc) m (env, init)

  let fold_env_ty_err_opt env f m init =
    fold
      (fun key v ((env, errs), acc) ->
        match f env key v acc with
        | ((env, Some err), acc) -> ((env, err :: errs), acc)
        | ((env, _), acc) -> ((env, errs), acc))
      m
      ((env, []), init)

  let elements m = fold (fun k v acc -> (k, v) :: acc) m []

  let map_env f env m =
    fold_env
      env
      (fun env key v map ->
        let (env, v) = f env key v in
        (env, add key v map))
      m
      empty

  let map_env_ty_err_opt f env m ~combine_ty_errs =
    let ((env, errs), res) =
      fold_env_ty_err_opt
        env
        (fun env key v map ->
          let (env, v) = f env key v in
          (env, add key v map))
        m
        empty
    in
    ((env, combine_ty_errs errs), res)

  let filter_map (f : 'a -> 'b option) m =
    m
    |> map f
    |> merge
         (fun _k _v v ->
           match v with
           | Some (Some v) -> Some v
           | Some None
           | None ->
             None)
         empty

  let filter_opt m = filter_map (fun x -> x) m

  let of_list elts =
    List.fold_left
      begin
        (fun acc (key, value) -> add key value acc)
      end
      empty
      elts

  let of_function domain f =
    List.fold_left
      begin
        (fun acc key -> add key (f key) acc)
      end
      empty
      domain

  let add ?combine key new_value map =
    match combine with
    | None -> add key new_value map
    | Some combine -> begin
      match find_opt key map with
      | None -> add key new_value map
      | Some old_value -> add key (combine old_value new_value) map
    end

  let ident_map f map =
    let (map_, changed) =
      fold
        (fun key item (map_, changed) ->
          let item_ = f item in
          (add key item_ map_, changed || item_ != item))
        map
        (empty, false)
    in
    if changed then
      map_
    else
      map

  let ident_map_key ?combine f map =
    let (map_, changed) =
      fold
        (fun key item (map_, changed) ->
          let new_key = f key in
          (add ?combine new_key item map_, changed || new_key != key))
        map
        (empty, false)
    in
    if changed then
      map_
    else
      map

  let for_all2 ~f m1 m2 =
    let key_bool_map =
      merge (fun k v1opt v2opt -> Some (f k v1opt v2opt)) m1 m2
    in
    for_all (fun _k b -> b) key_bool_map

  let make_pp pp_key pp_data fmt x =
    Format.fprintf fmt "@[<hv 2>{";
    let bindings = bindings x in
    (match bindings with
    | [] -> ()
    | _ -> Format.fprintf fmt " ");
    ignore
      (List.fold_left
         (fun sep (key, data) ->
           if sep then Format.fprintf fmt ";@ ";
           Format.fprintf fmt "@[";
           pp_key fmt key;
           Format.fprintf fmt " ->@ ";
           pp_data fmt data;
           Format.fprintf fmt "@]";
           true)
         false
         bindings);
    (match bindings with
    | [] -> ()
    | _ -> Format.fprintf fmt " ");
    Format.fprintf fmt "}@]"
end
