/-
Copyright (c) 2024-2025 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/
import VersoManual
open Verso.Genre.Manual

-- Here, `inlines!` is a macro that parses a string constant into Verso inline elements

def someThesis : Thesis where
  title := inlines!"A Great Thesis"
  author := inlines!"A. Great Student"
  year := 2025
  university := inlines!"A University"
  degree := inlines!"Something"

def somePaper : InProceedings where
  title := inlines!"Grommulation of Flying Lambdas"
  authors := #[inlines!"A. Great Student"]
  year := 2025
  booktitle := inlines!"Proceedings of the Best Conference Ever"

def someArXiv : ArXiv where
  title := inlines!"Grommulation of Flying Lambdas"
  authors := #[inlines!"A. Great Student"]
  year := 2025
  id := "...insert arXiv id here..."

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

/-
@inproceedings{lundberg2020hoare,
  title={Hoare-style logic for unstructured programs},
  author={Lundberg, Didrik and Guanciale, Roberto and Lindner, Andreas and Dam, Mads},
  booktitle={International Conference on Software Engineering and Formal Methods},
  pages={193--213},
  year={2020},
  organization={Springer}
}
-/
