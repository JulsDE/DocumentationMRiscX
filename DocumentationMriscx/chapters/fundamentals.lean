import VersoManual

import DocumentationMriscx.Meta
import DocumentationMriscx.Papers

import MRiscX

open DocumentationMriscx
open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Lean.MessageSeverity

set_option pp.rawOnError true

#doc (Manual) "Fundamentals" =>
%%%
htmlSplit := .never
tag := "fundamentals"
%%%

# The Assembly Language
%%%
tag := "assembly"
%%%
The `MRiscX` assembly language emulates the `RISC-V` assembly language from
[The RISC-V Instruction Set Manual Volume I: Unprivileged ISA](https://csg.csail.mit.edu/6.375/6_375_2019_www/resources/riscv-spec.pdf#page=155).

Let's start right away by inspecting some example code:
```lean
def some_code :=  mriscx
                    start:  li x 10, 5
                            li x 3, 2
                            li x 5, 123
                            la x 6, 0x098

                    label1:
                            add x 5, x 5, x 3
                            xor x 4, x 3, x 5
                            sw x 4, x 6
                            addi x 6, x 6, 1
                            beq x 10, x 3, finish

                    label2: subi x 10, x 10, 1
                            j label1

                    finish:
                  end
```

As you can see, to write code, use the keywords `mriscx` and `end`.
Between these keywords, you can define labels and `RISC-V` instructions.
It is not permitted to have instructions without a label as their "parent", but you may
have labels without any instructions (see the `finish` label in the example).
Additionally, each instruction must be followed by a newline (or a semicolon).

Unfortunately, in the current version of `MRiscX`, a space in the register name
between the `x` and the number is required.


## Available Instructions
%%%
tag := "availableInstructions"
%%%

In the current version of `MRiscX`, not all `RISC-V` instructions are available.
Here is a list of the instructions which are implemented yet:


{docstring Instr}



# Hoare-Logic
%%%
tag := "hoare-logic"
%%%

Hoare-logic is a formal system for verifying the correctness of structured
imperative programs
{margin}[{index}[Structured Programming]Structured Programming := Programming,
that does not use `goto`.].
Its goal is to enable the precise formulation and proof of statements about
program behavior.
To this end, Hoare-logic provides a set of logical rules that support rigorous
reasoning about the correctness of computer programs.

At its core, Hoare-logic combines two key ideas: expressing program
specifications in a clear and
natural way, and applying a structured proof technique to show that programs
satisfy these
specifications. The term structured refers to the fact that the structure of
the proof mirrors the
structure of the program itself. This logic was first introduced by
{citet hoare1969axiomatic}[].


## Hoare-Triples
A central element of Hoare-logic is the Hoare-triple. A Hoare-triple
is a statement about the state of a machine before and after the execution
of a command. By default, such a triple is noted as follows:

$$`
\{P\} c \{Q\}
`

$`P` and $`Q` are logical statements about the state before and after the
execution of the program segment $`c`.
What exactly these statements describe depends on the structure of the
respective machine state.
For example, they may refer to variable assignments, the contents of memory,
register values, or the value of the program counter.
The Hoare-triple now states:


If command $`c` begins execution in a state that satisfies statement $`P`,
and if $`c` eventually terminates in a state, then that final state satisfies
statement $`Q`.
The statement $`P` is called the {index}[Precondition] precondition of the
triple, and $`Q` is the
{index}[Postcondition] postcondition.

Example:
```
{x = 0} x := x + 1 {x = 1}
```

This Hoare-triple states:
If there is a state in which $`x=0` applies, and then the code `x := x + 1`
is executed, then $`x = 1` applies afterwards.


# Extension Of The Hoare-Logic $`\mathcal{L}_{AS}`
%%%
tag := "l_as"
%%%

The “original” Hoare-logic cannot be applied without restriction to all programs
and architectures. In structured programming, there are no restrictions on the
application of Hoare-logic, as the sequence of commands is precisely defined.
It is always clearly defined which command
will be executed next, and there is no possibility of jumping to any arbitrary
command. A sequential chain is formed in which each link must be executed one
after the other. This is not the case in unstructured programming
{margin}[{index}[Unstructured Programming]
Unstructured Programming := Programming, that uses `goto`].
Jump commands such as `goto` can be used to jump to any point in
the code.
Due to these restrictions on control flow and the limited ability
to reason about intermediate program points - which is required to support complete
correctness - the “classical” Hoare-triples are unsuitable for unstructured programs
{citep lundberg2020hoare}[].
Since `MRiscX` contains elements of unstructured programming,
an extended form of Hoare-logic is used, as presented by {citet lundberg2020hoare}[].



In the following, the functions {lean}`MState.runOneStep` is a function, which executes a
single instruction and therefore transforms a machine state $`s` into a machine state $`s'`.
The function {lean}`MState.runNSteps` is the $`n`-th iteration of {lean}`MState.runOneStep`.
{lean}`MState.pc` represents the value the {lean}`ProgramCounter` points to in a machine state
$`s`.
These two functions substitute the functions *nxt* and *lbl* in the
{index}[`weak transition relation`] in the paper {citep lundberg2020hoare}[].
With those functions, the weak transition relation in `MRiscX` is defined as follows:


```lean
namespace myNameSpace
def weak (s s' : MState) (L_w L_b : Set UInt64)
    (c : Code) : Prop :=
  s.code = c →
  ∃ (n:Nat), n > 0 ∧ s.runNSteps n = s' ∧ (s'.pc) ∈ L_w ∧
  ∀ (n':Nat), 0 < n' ∧ n' < n →
  (s.runNSteps n').pc ∉ (L_w ∪ L_b)
```
{docstring weak}

The {lean}`weak` transition relation has two machine states,
$`s` and $`s'`, and two sets of lines, $`L_W` and $`L_B`, as arguments.
This relation now states the following:

If $`n` steps are taken from state $`s`, state $`s'` is reached.
The PC of $`s'` points to a line that is an element of $`L_W`.
$`n` must be greater than 0.
Furthermore, there is no number $`n'` with $`0 < n' < n`
such that after $`n'` steps from state $`s`, state $`s'` is reached, whose PC also points to a
line in $`L_W \cup L_B` {citep lundberg2020hoare}[].
The `weak transition relation` is deterministic and partial,
since a program that starts in $`s` may never reach $`L_W`.
It also guarantees that no intermediate state  $`s''` "between" $`s` and $`s'` exists with
`s''.pc` $`\in L_W \cup L_B`.

With the help of this relation, unambiguous statements can be made about the flow of the program.

In order to formulate a Hoare-triple, the function {lean}`hoare_triple_up` can be used.
This function is inspired by the
$`\text{judgment of } \mathcal{L}_\text{{AS}}` in {citep lundberg2020hoare}[]


This {lean}`hoare_triple_up` function is defined as follows:
```lean
def hoare_triple_up (P Q : Assertion) (l : UInt64)
    (L_w L_b : Set UInt64) (c : Code) :=
  L_w ∩ L_b = ∅ →
  L_w ≠ ∅ →
  ∀ (s : MState), s.code = c →
  s.pc = l →
  P s →
  ∃ (s' : MState),
  (weak s s' L_w L_b c) ∧ Q s' ∧ s'.pc ∉ L_b

end myNameSpace
```
{docstring hoare_triple_up}

The notation introduced for a Hoare-triple looks like this:
```lean
example (P Q : Prop) (l : UInt64) (L_w L_b : Set UInt64)
    (mriscx_code : Code):
  mriscx_code
  ⦃P⦄ l ↦ ⟨L_w | L_b⟩ ⦃Q⦄
  := by sorry
```
, where $`P` and $`Q` represent the pre- and postcondition


## Hoare-Rules
%%%
tag := "hoare-rules"
%%%


In {citep hoare1969axiomatic}[], Hoare provides some rules
that can be used to prove the correctness of a program.
Those rules were transferred by {citet lundberg2020hoare}[] to the
extension $`\mathcal{L}_\text{AS}`, except for the `axiom of assignment`.

The notation used below should be understood as follows:
Everything above the line represents the prerequisites.
In the case of rule `axiom of assignment`, there are no prerequisites,
but all other rules do have prerequisites.
The terms below the line indicate the conclusions that can be derived from the
assumptions.

The `axiom of assignment` forms an elemental piece of the
$$`
\frac{}{\{P [x \leftarrow f]\} \quad x \leftarrow f \quad \{P\}} \quad
  \textrm{\scriptsize axiom of assignment}
`

This rule means that if $`x` is a variable identifier and $`f` is an expression, then
$`P[x \leftarrow f]` is created by replacing all occurrences  of $`x` in $`P` with $`f`.

In the "conventional" Hoare-logic, the `rule of composition` enable

To derive new statements about programs from a known Hoare-triple, one of the next two rules
can be applied.
With the rule `PRE-STR`, the precondition of a Hoare-triple can be strengthened:
$$`
  (\models (\mathbf{lbl} = l) \wedge P_2 \implies P_1)
  \frac{[P_1]l \rightarrow \langle L_W | L_B \rangle [Q]}
  {[P_2]l \rightarrow \langle L_W | L_B \rangle [Q]}
  \quad \textrm{\scriptsize PRE-STR}
`

{docstring PRE_STR +allowMissing}

The `POST-WEAK` rule allows for a weakening of the postcondition:

$$`
  (\models (\mathbf{lbl} \in L_W) \wedge Q_1 \implies Q_2)
  \frac{[P]l \xrightarrow{I}\langle L_W | L_B \rangle [Q_1]}
  {[P]l \rightarrow\langle L_W | L_B \rangle [Q_2]}
  \quad \textrm{\scriptsize POST-WEAK}
`

{docstring POST_WEAK +allowMissing}

It should be noted that the
rules `PRE-STR` and `POST-WEAK` require that the implications for states at the
entry and exit points ($`l` and $`L_W`, respectively).



The next rule enables the merge of two program sequences into one:
$$`
  \begin{pmatrix}
      \models L'_W \subseteq L_B \\
      \models L_W \cap L'_W = \emptyset
  \end{pmatrix}
  \frac{[P]l \rightarrow \langle L_W | L_B \rangle [R]
  \quad [R]L_W \rightarrow\langle L'_W | L'_B \rangle [Q]}
  {[P]l \rightarrow\langle L'_W | L_B \cap L_B' \rangle [Q]}
  \quad \textrm{\scriptsize S-SEQ}
`

{docstring S_SEQ +allowMissing}


This rule states that if both Hoare-triples $`\{P\} c_1 \{R\}` and
$`\{R\} c_2 \{Q\}` hold, they can be combined to derive the Hoare-triple
$`\{P\} c_1; c_2 \{Q\}`.

Note that the starting point of the second command sequence may consist of multiple lines
contained in $`L_W`.
The precondition $`L'_W \subseteq L_B` ensures that none of the final lines have already
been visited in the first segment ($`l \rightarrow \langle L_W \mid L_B \rangle`).

To avoid any ambiguity regarding visited lines, we additionally assume that
$`L_W \cap L'_W = \emptyset`.


An essential function in computer programs is the use of loops, which execute a chain of commands
repeatedly until a certain condition $`B` no longer applies.
Such a loop can be created in unstructured programs using a `jump` command.
In order to prove statements about
programs with loops, the rule `S-LOOP` is required. To apply this rule, a loop condition $`B`,
a loop invariant $`I` and a loop variant $`V` are required.
The special feature of $`I` is that it is a statement that is true both before and after each loop
iteration.
Therefore, $`I` remains valid regardless of the number of loop iterations - even if the loop is not
executed a single time.
On the opposite sits the loop variant.
The loop variant is an element or statement $`V` from a well-ordered set
$`W` with $`<` as the order relation.
Due to the well-ordering, the set $`W` has a smallest element, which means that there cannot
be an infinite chain with $`x_1 > x_2 > \dots`. It now needs to
be shown that the value of $`V` decreases strictly monotonically, i.e., it decreases after
each loop iteration.
If this can be shown, the loop must terminate at some point, since the value of $`V` can only
decrease a finite number of times.
For this proof, the variable $`x` is introduced, which is not used in any other way within a
program.

This whole concept is formalized in the rule `S-LOOP` as follows:
$$`
\begin{pmatrix}
    \models l \notin L_W \\
    \models l \notin L_B
\end{pmatrix}
\frac{
    \begin{matrix}
        [B \wedge V = x]l \xrightarrow{I} \langle \{l\} \cup L_W | L_B \rangle [\textrm{\textbf{lbl}} = l \wedge V < x] \\
        [\neg B \wedge I]l \rightarrow \langle L_W | L_B \rangle [Q]
    \end{matrix}
    }
    {[I]l \rightarrow \langle L_W | L_B\rangle [Q]}
    \quad \textrm{\scriptsize S-LOOP}
`

{docstring S_LOOP}


The rule `S-LOOP` describes two states of a loop.
On the one hand, there is the loop itself, which is bound to condition $`B` and contains both the
loop invariant $`I` and the loop variant $`V`. The union of $`\{l\}` and $`L_W` and the
postcondition $`\mathbf{lbl} = l` ensure that at the end of a loop iteration, the PC points back
to the beginning of the loop.
On the other hand, there is the case where $`\neg B` applies. Under these circumstances,
the loop body is exited, and a jump is made to one of the lines stored in $`L_W`.

Conditional branches are also an essential part of a computer program, as they enable an individual
response to different states.

The rule `S-COND` can be used to handle conditional branchen during a proof of formal correctness.
$$`
    \frac{
        [P \wedge B]l \rightarrow \langle L_W | L_B \rangle [Q]
        \quad [P \wedge \neg B]l \rightarrow \langle L_W | L_B \rangle [Q]
    }
    {
        [P]l \rightarrow \langle L_W | L_B\rangle [Q]
    }
    \quad \textrm{\scriptsize S-COND}
`

{docstring S_COND}


Since $`\mathcal{L}_\text{{AS}}` works with sets of program lines, rules are needed to
be able to adjust them during a proof.
For this purpose, the following three rules were defined in {citet lundberg2020hoare}[],
which allow the contents of the sets $`L_W` and $`L_B` to be manipulated.

$$`
    \frac{
            [P]l \rightarrow \langle L_W | L_B\rangle [Q]
        }
        {
            [P]l \rightarrow \langle L_W | L_B \backslash L\rangle [Q]
        }
        \quad \textrm{\scriptsize BL-SUBSET}
`

{docstring BL_SUBSET}

$$`
    \begin{pmatrix}
        \models L \subseteq L_B
    \end{pmatrix}
    \frac{
        \begin{matrix}
            [P]l \rightarrow \langle L_W | L_B \rangle [Q]
        \end{matrix}
        }
        {
            [P]l \rightarrow \langle L_W \cup L | L_B \backslash L\rangle [Q]
        }
        \quad \textrm{\scriptsize BL-TO-WL}
`

{docstring BL_TO_WL}


$$`
    \begin{pmatrix}
        \models L \subset L_W \\
        \models Q \implies \textrm{\textbf{lbl}} \notin L
    \end{pmatrix}
    \frac{
        \begin{matrix}
            [P]l \rightarrow \langle L_W | L_B \rangle [Q]
        \end{matrix}
        }
        {
            [P]l \rightarrow \langle L_W \backslash L | L_B \cup L\rangle [Q]
        }
        \quad \textrm{\scriptsize WL-TO-BL}
`

{docstring WL_TO_BL}


## Specification Of The Instructions
%%%
tag := "specification_instr"
%%%
In order to show the formal correctness of each instruction, the specification
was defined of every instruction respectively.

Those specifications can be found in the file
[`MRiscX/Semantics/Specification.lean`](https://github.com/JulsDE/MRiscX/blob/main/MRiscX/Semantics/Specification.lean).

For these specifications, the `axiom of assignment` was used.

{docstring specification_LoadImmediate}

By defining the specification for every available instruction and delivering a proof,
the formal correctness of the interpreter is shown.
