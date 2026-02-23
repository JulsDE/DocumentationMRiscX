/-
Copyright (c) 2024–2025 Lean FRO LLC
Copyright (c) 2026 Julius Marx

Author: David Thrane Christiansen
Modifications: Julius Marx

Released under Apache 2.0 license as described in the file LICENSE.

This file has been modified from the original version.
-/

import VersoManual
open Verso.Genre.Manual


def hoare1969axiomatic : Article where
  title := inlines!"An axiomatic basis for computer programming"
  authors := #[inlines!"Charles Antony Richard Hoare"]
  journal := inlines!"Communications of the ACM"
  year := 1969
  volume := inlines!"12"
  number := inlines!"10"
  pages := some (576, 580)
  url := some "https://dl.acm.org/doi/abs/10.1145/363235.363259"
  month := none

def lundberg2020hoare : InProceedings where
  title := inlines!"Hoare-style logic for unstructured programs"
  authors :=  #[inlines!"Didrik Lundberg", inlines!"Roberto Guanciale", inlines!"Andreas Lindner",
                inlines!"Mads Dam"]
  year := 2020
  booktitle := inlines!"International Conference on Software Engineering and Formal Methods"
  editors := none
  series := none
  url := some "https://link.springer.com/chapter/10.1007/978-3-030-58768-0_11"
