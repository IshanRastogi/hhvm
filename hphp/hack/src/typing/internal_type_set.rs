// Copyright (c) Facebook, Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the "hack" directory of this source tree.

use typing_collections_rust::Set;

use crate::InternalType;

pub type ITySet<'a> = Set<'a, InternalType<'a>>;
