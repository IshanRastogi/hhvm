(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the "hack" directory of this source tree.
 *
 *)
open Hh_prelude

let on_user_attributes on_error us ~ctx =
  let seen = Caml.Hashtbl.create 0 in
  let dedup (attrs, err_acc) (Aast.{ ua_name = (pos, attr_name); _ } as attr) =
    match Caml.Hashtbl.find_opt seen attr_name with
    | Some prev_pos ->
      let err =
        Naming_phase_error.naming
        @@ Naming_error.Duplicate_user_attribute { pos; prev_pos; attr_name }
      in
      (attrs, err :: err_acc)
    | _ ->
      Caml.Hashtbl.add seen attr_name pos;
      (attr :: attrs, err_acc)
  in
  let (us, errs) =
    Tuple2.map_fst ~f:List.rev @@ List.fold_left us ~init:([], []) ~f:dedup
  in
  List.iter ~f:on_error errs;
  (ctx, Ok us)

let pass on_error =
  let id = Aast.Pass.identity () in
  Naming_phase_pass.top_down
    Aast.Pass.
      {
        id with
        on_ty_user_attributes =
          Some (fun elem ~ctx -> on_user_attributes on_error elem ~ctx);
      }
