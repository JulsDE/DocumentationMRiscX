import VersoManual
import DocumentationMriscx.Meta.Lean
import MRiscX

open DocumentationMriscx Verso.Genre Manual Verso.Genre.Manual.InlineLean


set_option pp.rawOnError true

#doc (Manual) "Writing a specification" =>
%%%
htmlSplit := .never
tag := "specification"
%%%

After understanding the fundamentals, lets have a look how we can use this
to actually prove some code.

Let's start by writing down the pre-, and postcondition of a program!

# Pre- And Postcondition
%%%
tag := "preAndPostcondition"
%%%

First of all, we need to be aware what our program is actually doing.
Once this is clear, we want to express this in first-order predicate logic.

Let's take a look at the following two examples:
```lean
#check
  mriscx
    first:
            li x 1, 1
            li x 2, 43
            add x 3, x 1, x 2

    finish:
  end
```
we expect after execution this program,
that the registers $`x_1` and $`x_2` hold the values
which were loaded into them, the register $`x_3` holds the result of the
addition of $`x_1` and $`x_2`.
That means, the specification of this code snippet should look something like this:
$$`x_1 = 1 \wedge x_2 = 43 \wedge x_3 = x_1 + x_2`

The next example involves a loop:
```lean
variable (regWithAddr addr counter regWithValue
          length: UInt64)
#check
  mriscx
    first:
            la x regWithAddr, addr
            li x counter, length

    loop:
            beqz x counter, finish
            sw x regWithValue, x addr
            addi x addr, x addr, 1
            subi x counter, x counter, 1
            j loop

    finish:
  end

```

In this code, we have no concrete values, but some variables. This makes
the specification more general and we do not restrict the specification on
certain values.
So let's see what is happening here:

First, an address `addr` is loaded into a register `regWithAddr`.
Then, the loop is entered. It starts with a conditional jump, which happens when
the content of a register `counter` equals zero. If that is the case, we jump to the label
finish.
When the register holds a value greater than zero, the actual loop body is entered.
The content of a register `regWithValue` is stored into the memory at the address the
register `regWithAddr` holds.
Once this is done, the address inside the register `regWithAddr` is incremented by one,
the value the register `counter` holds is decremented by one and we jump back to the
label `loop`.

Furthermore, let $`\text{memory}(n)` denote the memory address $`n`.
Then, the specification of this program could be formulated as follows:

$$`
\begin{aligned}
\text{Pre} \; \coloneqq \;
& i < \text{length}
  \;\wedge\;
  \text{addr} + \text{length} - 1 < 2^{64} \\[0.5em]
\forall i \in \mathbb{U}_{64},\;
& \text{Pre}
  \;\rightarrow\;
  \text{memory}(\text{addr} + i)
  = x_{\text{regWithValue}}
\end{aligned}
`


So as you can see, we need multiple things to successfully write down a
correct specification:

1. First order logic with arithmetic expressions
2. Access to the values (registers, memory, ...) of a certain machine state

The point 1. is already provided by lean itself, so just need to somehow
access a machine state.
`MRiscX` offers a simple way to do this.

Inside the `⦃⦄` braces, we can write down first order logic formulas just like
in usual terms of type {lean}`Prop`. Additionally, there are the following custom term,
which can be used:

* `⸨terminated⸩`

  This term is the {lean}`MState.terminated` flag.
  It indicates whether the program has terminated and whether the current machine state is legal.
  If this flag is `true`, the machine state is no longer legal, and no further instructions
  can be executed.
  Consequently, {lean}`⦃¬⸨terminated⸩⦄` serves as a precondition that is almost always
  required to ensure that instructions can be executed and, ultimately, to establish the
  functional correctness of a program.

* `⸨pc⸩`

  With this term, we can define the value of the {lean}`MState.pc`. Using this, we can
  ensure that the {lean}`MState.pc` holds a certain value before or after
  executing a program. Note, that `l` also ensures, that the {lean}`MState.pc` points to
  a certain line before executing the program, so this term is often only useful in the
  postcondition.

* `x[n]`, where $`n` is either a number of type {lean}`UInt64` or an identifier
  ({lean}`Lean.Parser.ident`)

  Using this term we are able to define a value $`n` for a register $`x_n` in
  {lean}`MState.registers`.
  As already mentioned, this $`n` can either be a number of type {lean}`UInt64` or
  an identifier.
  This means, that the terms
  ```lean
  variable (n v : UInt64)
  #check ⦃x[n] = v⦄
  #check ⦃x[1] = 42⦄
  #check ⦃x[1] = 0x4411⦄
  ```
  are all legal.
  Also note, that lean inherently supports hexadecimal numbers, so {lean}`⦃x[1] = 0x4411⦄` is legal
  and can be used to describe that a certain register holds a memory address.

* `mem[t]`, where `t` is a {lean}`Lean.Term`. This includes every custom term presented here.

  This term can be used to define a value of a certain place in the {lean}`MState.memory`.
  Since it is possible to use the regular terms of lean as well as the custom terms,
  we can load an address into a register, manipulate it and then use this register inside
  the square brackets.

  ```lean
  #check ⦃mem[0x7ffe5367e044] = 4123⦄
  #check ⦃mem[x[2] + 1] = x[4] + x[5]⦄
  ```

* `labels[i]`, where `i` is of type {lean}`Lean.Ident`.

  Using this, we can ensure either that the label `i` exists on a specific line or that it does not
  exist at all. Note, that the labels inside the code sections are already stored inside the
  {lean}`Code.labels`, so they do not nee to be specified within the pre- or postcondition.

  This term returns an {lean}`Option UInt64`.
  ```lean
  #check ⦃labels[first] = some 0⦄
  #check ⦃labels[_L_store] = none⦄
  ```

To wrap things up, here is an example of a Hoare-triple with most of the terms presented:
  ```lean
  #check
      mriscx
        _start:
                la x 2, 0x7ffe5367e044
                addi x 2, x 2, 1
                xori x 3, x 4, 412
                sw x 3, x 2
      end
      ⦃¬⸨terminated⸩⦄
      "_start" ↦ ⟨{"_start" + 4} | {n | n > "_start" + 4} ∪ {"_start"}⟩
      ⦃x[3] = x[4] ^^^ 412 ∧ mem[x[2] + 1] = x[3]⦄
  ```

# ProgramCounter, Black- and Whitelist
%%%
tag := "pc-black-whitelist"
%%%

As already shown in {ref "l_as"}[the introduction of the Hoare-logic] which
is used, we need to specify exactly where the {lean}`ProgramCounter` points to
before executing the program. Also, we need to provide a black- and whitelist
in order to ensure, that the {lean}`ProgramCounter` just visits the lines
we intend to proof the formal correctness of.
The {lean}`ProgramCounter` is of type {lean}`UInt64` and the black-, and
whitelist are of type {lean}`Set UInt64`.
We can use the usual syntax here.

The value required for the {lean}`ProgramCounter` is the line which the PC
points to, before executing the first instruction. So basically, this should
be the first instruction we want to be executed.
After executing one instruction, the {lean}`ProgramCounter` points to the next
instruction.

We define the whitelist as a set of lines which contains any lines the PC might
point to *after* the program terminated.



So if we have a program like this:

```lean
#check
  mriscx
    _start: li x 1, 2
  end
```

the Hoare-triple should look like this

```lean
example :
  mriscx
    _start: li x 1, 2
  end
  ⦃¬⸨terminated⸩⦄
  0 ↦ ⟨{1} | {n:UInt64 | n > 1} ∪ {0}⟩
  ⦃true ∧ ¬⸨terminated⸩⦄
  := by
  sorry
```

As you can see, we want to stop when the PC points to line 1, that is, the line
immediately following the instruction we want to inspect.
To make explicit something that can be slightly confusing when defining a
Hoare-triple, we write {lean}`{n : UInt64 | n > 1} ∪ {0}`
(which is simply a cumbersome way of writing {lean}`{n : UInt64 | n ≠ 1}`)
as the blacklist.
This choice is motivated by the fact that the $`\mathsf{weak}` function only
considers machine states that have executed at least one instruction.
Consequently, if we want to ensure that the PC does not visit the line where the
first instruction is located after at least one instruction has been executed,
we must include this line in the blacklist.
