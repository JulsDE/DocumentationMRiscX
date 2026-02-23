import VersoManual
import DocumentationMriscx.Meta.Lean
import MRiscX

open DocumentationMriscx Verso.Genre Manual Verso.Genre.Manual.InlineLean


set_option pp.rawOnError true


#doc (Manual) "Limitations" =>
%%%
htmlSplit := .never
tag := "limitation"
%%%

This DSL has some limitations, since it is still work in progress.
At the moment, it is a simple way to prove the formal correctness of simple,
sequential code. It can also be used to formally verify the correctness of some
more complex code (see
[OtpProof](https://github.com/JulsDE/MRiscX/blob/main/MRiscX/Examples/OtpProof.lean)
). Unfortunately for those proofs it becomes quite messy and you have to have a deep
understanding of `Lean` itself and how the model {lean}`MState` is implemented.
Also, you need to be very familiar with the {ref "hoare-logic"}[Hoare-logic].

Additionally, there are some features missing which are currently implemented or at least on the
TODO list. This list looks like this at the moment:

* Completion of assembly instructions
  + As shown in the {ref "availableInstructions"}[list of available instructions], several
    instructions are missing. These will be implemented in future versions.

* Remove the space in the register names
  + As mentioned in the {ref "assembly"}[assembly chapter], in the current version is a
    space required between the `x` and the number of the register.

* Incorporation of calling conventions
  + Currently, it is possible to modify the contents of register $`x_0`. In `RISC-V`, however, this
    register is hard-wired to zero and cannot be changed.
  + This restriction, along with additional `RISC-V` calling conventions, should be formally
    integrated into `MRiscX`.

* Multiple register names
  + Support for register aliases beyond $`x_n`.
  + For example, registers such as $`t_n` or $`a_n` should be available.

* Proof automation
  + At present, only the application of the rule `S-SEQ` is automated. This should be extended to
    automate the application of additional Hoare rules.
  + Currently, the tactic `apply_spec` can be used to apply a specification. However, it still
    requires manually providing details such as the current program counter location. This process
    could be further automated, ideally to the point where even the name of the required
    specification is inferred automatically.
  + We aim to support multiple levels of proof automation. For instance, users should be able to
    apply tactics such as `sapply_s_seq` to follow the verification process step by step, or use
    more advanced tactics like `auto_seq` - or even a single high-level tactic - that automatically
    verifies all steps at once for fast and convenient formal verification of assembly code.
