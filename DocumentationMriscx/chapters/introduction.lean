import VersoManual
import DocumentationMriscx.Meta.Lean
import MRiscX

open DocumentationMriscx Verso.Genre Manual Verso.Genre.Manual.InlineLean


set_option pp.rawOnError true

#doc (Manual) "Introduction" =>
%%%
htmlSplit := .never
tag := "intro"
%%%

# What is `MRiscX`

`MRiscX` provides a way to write down and run `RISC-V` assembly in `Lean`.
Additionally, it enables the possibility to annotate the code with a
specification in form of a Hoare-triple.
Using this Hoare-triple, the annotated `RISC-V` assembly code can be
formally verified to fulfill its specification.
`MRiscX` also offers various ways to automate the process of the proof on
different levels.

All of this leads to a convenient way, to get started with formal verification of source code
and `Lean4` itself.

# How does `MRiscX` look like

The concept of a Hoare-triple in `MRiscX` looks like this:

```lean
example (P Q : Prop) (l : UInt64)
        (L_W L_B : Set UInt64)
        (mriscx_code : Code) :
  mriscx_code
  ⦃P⦄ l ↦ ⟨L_W | L_B⟩ ⦃Q⦄
  := by sorry
```

But what is happening here?

The `example:` and `:= by sorry` is syntax provided by `Lean` itself.
With `example:` we can declare a theorem without the requirement to
provide a name. `:= by` is the
beginning of the proof section. All the other lines of the code above
are `MRiscX`-code. This is made possible by expanding the parser and elaborator
of `Lean`.

There are two main sections in a Hoare-triple, which in turn can be
divided into multiple subsections:

1. The `Code` section. For now, we just declared a variable of type {lean}`Code`,
but this can be replaced by actual `RISC-V` assembly code. More about this in the chapter
about the {ref "assembly"}[MRiscX assembly language].
2. The Hoare-triple: This section consists of three subsections
      1. The precondition `P`
      2. The lines which are visited during runtime of this program.
      This has the structure of `l ↦ ⟨L_W | L_B⟩`, where
            * `l` represent the line where the program starts
            (where the {lean}`ProgramCounter` {index}[PC](PC) points to
            before running the program).
            * `L_W` is the white list, a set containing all the lines where
            the PC might point to *after*
            executing the program. So when we want to let the program run for
            one line.
            * `L_B` is a white list. This set contains all the lines, which must
            not be visited during the runtime.
      3. The postcondition `Q`.

  More details about the {ref "hoare-logic"}[Hoare-logic] and {ref "hoare-triples"}[Hoare-triples]
  are going to be explained later in the {ref "fundamentals"}[fundamentals] chapter.

# First Example
Now we have seen how the general structure of a Hoare-triple in `MRiscX` looks like,
let's look at a more fleshed-out example:

```lean
example:
  mriscx
    first:  li x 0, 2
            li x 1, 0
            la x 2, 0x123
  end
  ⦃¬⸨terminated⸩⦄
  "first" ↦ ⟨{"first" + 3} | ({n:UInt64 | n = "first"}
                             ∪ {n:UInt64 | n > "first" + 3})⟩
  ⦃(x[0] = 2 ∧ x[1] = 0 ∧ x[2] = 0x123) ∧ ¬⸨terminated⸩⦄
:= by sorry
```


The notation for defining the specification in a Hoare-triples
will be presented in depth in chapter {ref "specification"}[].
For now, it should be enough to know, that `¬⸨terminated⸩` ensures that the
program did not terminate yet and the machine state is in a legal state and `x[n]` represents
the register $`x_n`.

To describe the example code above in words:

Let {index}[$`\mathbb{U}_{64}`]$`\mathbb{U}_{64}` be the finite set of all natural numbers from
$`0` to $`2^{64} - 1`.

Assume that the given machine state is in a legal state.
If we execute the assembly program starting at the label `"first"` and continue until the program
counter (PC) reaches the line `"first" + 3`, under the restriction that no line in
$`(\{n \in \mathbb{U}_{64} \mid n = \text{"first"}\} \cup
  \{n \in \mathbb{U}_{64} \mid n \gt \text{"first"} + 3\})`
is visited, then the following holds:

Register $`x_0` contains the value $`2`, register $`x_1` contains the value $`0`, and register
$`x_3` contains the address $`0x123`.
Moreover, the machine state remains valid after execution, meaning that the program can
continue with subsequent instructions.

In the next chapter, we will have a look on the theoretical fundamentals of the assembly
and the Hoare-logic to get a better understanding for what is actually happening here and how
you can use this, to verify your own code.
