import VersoManual
import DocumentationMriscx.Meta.Lean
import MRiscX

open DocumentationMriscx Verso.Genre Manual Verso.Genre.Manual.InlineLean


set_option pp.rawOnError true


#doc (Manual) "Process of Proving Formal Correctness" =>
%%%
htmlSplit := .never
tag := "proofProcess"
%%%

To enable a better user experience while proving the formal correctness of an implementation
in RISC-V assembly, some custom tactics were implemented.
These tactics enable multiple levels of proof automation.
In this chapter, those custom tactics are presented.

For a brief introduction to this topic, you can have a look at
[this section](https://www.youtube.com/watch?v=AeHt3IyoBc8&t=852s) of the talk about
`MRiscX` at
[Lean Together 2026](https://leanprover-community.github.io/lt2026/).

# Custom Tactics
%%%
tag := "customTactics"
%%%

:::tactic «tacticSapply_s_seqP:=_,R:=_,L_W:=_,L_W':=_,L_B:=_,L_B':=_»
:::

:::tactic «tacticSapply_s_seq''_,_,_,_,_»
:::

:::tactic "auto_seq"
:::

:::tactic "apply_spec"
:::

# General Idea in a Proof

The general idea of a proof of the formal correctness of an implementation looks like
this:

1. Identify:
  1) Sequential code sections
  2) Conditional branches
  3) Loops
2. Use the tactic `S_SEQ` (or the custom tactic `sapply_s_seq`) to isolate these sections.
3. These situations might come up:
  1) Sequential code sections
    * Use `S_SEQ` or some custom tactic (e.g. `auto_seq`)
      to "peel off" the last instruction and inspect
      it in isolation. You might have to think of an appropriate `R`.
    * Use the specification for the isolated instruction to formally verify the
      correctness of this single step.
    * Repeat the process.
  2) Conditional branches
    * Apply `S_COND`
    * Show that $`Q` is valid with
      1. $`P \wedge C`
      2. $`P \wedge \neg C`
      by going through both code sections and repeating from step 1.
  3) Loops
    * Apply `S_LOOP` by finding the condition `C` of the loop, the loop invariant `I`,
      and the loop variant `V` as described in the introduction to
      {ref "sloop"}[`S-LOOP`]
    * Show the formal correctness of the loop body when `C` is true (the condition
      for one loop iteration holds)
    * Show that the loop is exited when `¬C` (the condition
      for another loop iteration does not hold)

For some easy examples, have a look at the
[Example file](https://github.com/JulsDE/MRiscX/blob/main/MRiscX/Examples/Examples.lean).
There you can find how the custom tactics are applied to some small code examples.

A larger example can be seen in the file
[OtpProof](https://github.com/JulsDE/MRiscX/blob/main/MRiscX/Examples/OtpProof.lean).
Here, an implementation of the "One-Time-Pad" was formally verified.
Note that this example is quite old and should be refactored.
