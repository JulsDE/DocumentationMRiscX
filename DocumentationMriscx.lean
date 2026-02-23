/-
Copyright (c) 2024–2025 Lean FRO LLC
Copyright (c) 2026 Julius Marx

Author: David Thrane Christiansen
Modifications: Julius Marx

Released under Apache 2.0 license as described in the file LICENSE.

This file has been modified from the original version.
-/

import VersoManual
import DocumentationMriscx.Meta.Lean
import DocumentationMriscx.Papers
import DocumentationMriscx.chapters.introduction
import DocumentationMriscx.chapters.fundamentals
import DocumentationMriscx.chapters.specification
import DocumentationMriscx.chapters.proofProcess
import DocumentationMriscx.chapters.limitations
import MRiscX

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open DocumentationMriscx

set_option pp.rawOnError true


#doc (Manual) "Documentation MRiscX" =>

%%%
authors := ["Julius Marx"]
%%%

This documentation provides a brief introduction to the domain-specific language {index}[DSL](DSL)
`MRiscX`.
`MRiscX` was designed to lower the barrier to entry into the world of formal methods.
Embedded in `Lean`, `MRiscX` enables `RISC-V` assembly code to be easily annotated with formal
specifications, which can then be interactively verified.
By allowing the correctness of assembly programs to be proven with minimal effort, `MRiscX`
significantly simplifies the process of getting started with formal methods.

We begin with a short {ref "intro"}[introduction] to what `MRiscX` is and what it looks like.
Next, the {ref "fundamentals"}[fundamentals] are explained to provide the theoretical background on
which this DSL is built and to demonstrate how it can be used in practice.
Finally, we show how `MRiscX` can be applied to verify `RISC-V` assembly code.
In particular, we demonstrate how to formulate a {ref "specification"}[specification] of a program
as a Hoare-triple and provide guidance on applying the {ref "hoare-rules"}[Hoare-rules], along with
custom tactics, to carry out the {ref "proofProcess"}[process of proving] and verify the
program’s formal correctness.

For an introduction, you can watch this
[presentation of MRiscX](https://www.youtube.com/watch?v=AeHt3IyoBc8)
at the [Lean Together 2026](https://leanprover-community.github.io/lt2026/)

If there are any questions, do not hesitate to get in touch:
[julius.marx@hs-rm.de](mailto:julius.marx@hs-rm.de)

{include 1 DocumentationMriscx.chapters.introduction}
{include 1 DocumentationMriscx.chapters.fundamentals}
{include 1 DocumentationMriscx.chapters.specification}
{include 1 DocumentationMriscx.chapters.proofProcess}
{include 1 DocumentationMriscx.chapters.limitations}



# Index
%%%
number := false
tag := "index"
%%%

{theIndex}
