/-
Copyright (c) 2025 Lean FRO LLC
Copyright (c) 2026 Julius Marx

Author: David Thrane Christiansen
Modifications: Julius Marx

Released under Apache 2.0 license as described in the file LICENSE.

This file has been modified from the original version.
-/

import VersoManual

open Verso.Genre Manual
open Verso.Doc Elab
open Verso.ArgParse
open Lean

namespace DocumentationMriscx

block_extension Block.savedLean (file : String) (source : String) where
  data := .arr #[.str file, .str source]

  traverse _ _ _ := pure none
  toTeX := none
  toHtml := some fun _ goB _ _ contents =>
    contents.mapM goB

block_extension Block.savedImport (file : String) (source : String) where
  data := .arr #[.str file, .str source]

  traverse _ _ _ := pure none
  toTeX := none
  toHtml := some fun _ _ _ _ _ =>
    pure .empty

/--
Lean code that is saved to the examples file.
-/
@[code_block savedLean]
def savedLean : CodeBlockExpanderOf InlineLean.LeanBlockConfig
  | args, code => do
    let underlying ← InlineLean.lean args code
    ``(Block.other (Block.savedLean $(quote (← getFileName)) $(quote (code.getString))) #[$underlying])

/--
An import of some other module, to be located in the saved code. Not rendered.
-/
@[code_block]
def savedImport : CodeBlockExpanderOf Unit
  | (), code => do
    ``(Block.other (Block.savedImport $(quote (← getFileName)) $(quote (code.getString))) #[])

/--
Comments to be added as module docstrings to the examples file.
-/
@[code_block]
def savedComment : CodeBlockExpanderOf Unit
  | (), code => do
    let str := code.getString.trimAsciiEnd.copy
    let comment := s!"/-!\n{str}\n-/"
    ``(Block.other (Block.savedLean $(quote (← getFileName)) $(quote comment)) #[])
