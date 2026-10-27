# MPRI FUN Programming Project 2026-2027: Zippy LL(1) Parser Combinators

This is the programming project
that accompanies the course
[Functional programming and type systems](https://gitlab.inria.fr/fpottier/mpri-2.4-public/blob/master/README.md)
for the year 2026-2027.

In this project,
you are expected to implement (in OCaml)
a library of parser combinators,
based on the paper
["LL(1) Parsing with Derivatives and Zippers"](https://arxiv.org/pdf/1911.12737)
by Romain Edelmann, Jad Hamza, and Viktor Kunčak.
Then, using these combinators,
you are expected to implement
a parser for a toy programming language.
Finally, you are expected to implement
an interpreter for this toy language.

## Skeleton

As a starting point, we provide
[a skeleton](https://github.com/fpottier/mpri-fun-zippy-parsing/)
where a few files are already written.
Please clone this repository
and create your own repository instead:
```bash
  git clone https://github.com/fpottier/mpri-fun-zippy-parsing/
  cd mpri-fun-zippy-parsing
  rm -rf .git
  git init
```
Because we wish to give you ample freedom
and to spare you the difficulty of understanding a large code base,
only a few files are provided; the rest is up to you.

* The files `dune-project` and `Makefile` and `src/dune`
  let you compile, clean up,
  and test by running `make`, `make clean`, and `make test`.

* The test suite in the directory `test/`
  comprises 1111 toy programs of various sizes.
  The source code of each test program is stored in a file named `test/*/XXX.toy`
  and its expected value is stored in a file named `test/*/XXX.exp`.
  Every test program is well-formed and has type `int`
  according to the rules of the toy language.
  Therefore its expected value is an integer value.
  The files `test/*/dune` instruct the compilation manager
  how to run these tests.

* The file `src/toy.ml` defines the abstract syntax
  of the toy language.

* The file `src/token.ml` defines the tokens and token kinds
  of the toy language.

* The file `src/lexer.mll` contains a lexical analyzer, or *lexer*,
  for the toy language. Its main function,
  `Lexer.main`, has type `lexbuf -> Token.token`,
  where the type of mutable lexing buffers, `lexbuf`,
  is defined in OCaml's standard library module
  [Lexing](https://ocaml.org/manual/5.5/api/Lexing.html).

* The file `src/zippy.mli` contains the interface of the parser combinator
  library that you are expected to implement. It is entirely independent
  of the toy language.

The files `src/zippy.ml` and `src/main.ml` are empty. It is up to you to
complete these files. You are welcome to introduce more files, if necessary,
so as to cleanly structure your code in multiple modules.

## Assignment

Please obey the following requirements:

* The command `dune exec src/main.exe -- interpret` must read (on the standard
  input channel) a program in the toy language, parse it, interpret it, and
  print its value, which can be expected to be an integer value.
  More information about the toy language is provided further on.

* Therefore, `make test` must succeed: it must produce no output
  and must terminate with exit code 0.

* The time complexity of your parser should be linear in the length of the input.
  This will be tested using the provided test suite as well as extra tests of
  higher sizes. As an indication, on a reasonably recent and powerful laptop
  computer, the command `dune clean && dune build && time dune runtest` reports
  that all 1111 tests are run in about 0.7 seconds of "real" (wall-clock) time.

* Your parser of the toy language must be built using the LL(1) parser
  combinators that are described in the file `src/zippy.mli` and implemented
  (by you) in the file `src/zippy.ml`. The use of other parsing techniques or
  tools is not permitted.

* It is permitted to rely on the external library `fix`,
  which offers a convenient
  [least fixed point computation](https://cambium.inria.fr/~fpottier/fix/doc/fix/Fix/Fix/index.html)
  algorithm.
  Of course you may also write your own algorithm.

* The file `DESCRIPTION.md` must be completed with a high-level description of
  your work. It is up to you to decide what to describe in this file. For
  example, we would expect you to explain what questions, difficulties, or
  problems you encountered and what design decisions you made. Please do not
  go into too much detail, and keep this description relatively short. As an
  indication, we expect between 200 and 1000 words.

* Submit your project before **Wednesday, February 10, 2027 at 23:00**.
  To create an archive of your repository, use `make archive`.
  (By default, your login name is used as the base name of the archive.
  This can be changed, if desired, by setting the variable `NAME`
  in the file `Makefile`.)
  Verify that your archive seems well-formed by using `make test_archive`.
  Then send the archive by email to [François Pottier](mailto:francois.pottier@inria.fr).

## The toy language

### Syntax

At a somewhat abstract and informal level, the syntax of the toy language can
be described as follows. There is just one syntactic category, namely
expressions. An *expression* can be:

* a variable; examples are `x`, `y`, `f`, and `z0`.
* an integer literal; examples are `0` and `12`.
* a function application,
  where the function is a variable
  and the actual arguments
  form a parenthesized, possibly empty, comma-separated
  list of expressions;
  examples are `f()` and `g(x+2, 12)`.
* a parenthesized expression; an example is `(2+2)`.
* a non-empty list of expressions,
  separated with the binary operators `*` and `/`;
  examples are `3*(x-1)/2` and `x*y*f(z)`.
* a non-empty list of expressions,
  separated with the binary operators `+` and `-`;
  examples are `3+x-1` and `1+y/2`.
* a local variable definition;
  an example is `let x = 21 in x+x`.
* an anonymous function,
  where the formal parameters
  form a parenthesized, possibly empty, comma-separated
  list of variables;
  examples are `fun () -> 0` and `fun (x, y) -> x+y`.
* a sum;
  an example is `for i from 1 to 10 sum i`,
  whose value is `55`.

This informal description is ambiguous. To eliminate ambiguity
and obtain an unambiguous context-free grammar of the toy language,
it is necessary to stratify the language into several layers.
One possible formulation is as follows:

* a *factor* is
  - a variable, or
  - an integer literal, or
  - a function application, or
  - a parenthesized expression.

* a *term* is
  - a non-empty list of factors,
    separated with multiplicative operators.

* an *expression* is
  - a non-empty list of terms,
    separated with additive operators, or
  - a local definition, or
  - an anonymous function, or
  - a sum.

This is a good informal description,
though perhaps still slightly imprecise in some ways.
It is up to you to define a context-free grammar for the toy language
and to express this grammar in terms of the parser combinators
described in the file `src/zippy.mli`.
For the parsing algorithm to work,
the grammar must be in the class LL(1).

### Semantics

The toy language can be viewed as a pure λ-calculus
extended with primitive integers.
Therefore, a value is either an integer value or a function.
The primitive integers are 63-bit machine integers,
as in OCaml.
Division by zero does not fail; it returns zero.

## Suggestions and hints

Here are some suggestions and hints.

* In the parser combinator library (`src/zippy.ml`),
  the combinators `choose` and `maybe`
  can be defined in terms of other combinators.

* Similarly, the combinator `star` can be defined
  in terms of other combinators, including `fix`.
  The combinator `fix` lets you define a recursive non-terminal symbol `X`,
  that is, a symbol `X` together with a production `X ::= E`
  where the right-hand side `E` refers to `X`.

* The combinator `fix` itself can be defined using `declare`,
  which provides a general mechanism
  for defining *several* mutually recursive non-terminal symbols.

To approach the construction of the combinator library,
we suggest the following three stages.
Stages 2 and 3 are independent of one another
and can be attacked in an arbitrary order.

* In the first stage, simplify the type `'a syntax` by removing its parameter `'a`.
  Ignore (remove) the combinators `map`, `star`, `fix`, `declare`. The type of
  the function `parse` is then `syntax -> token list -> bool`. It is a *recognizer*:
  the call `parse s toks` determines whether the word `toks` (a sequence of tokens)
  is valid or invalid according to the syntax description `s`.
  A syntax description `s` can be viewed as a language,
  that is, a set of words.

  In this first stage, the internal definition of the type `syntax`
  should be an algebraic data type.

  On this algebraic data type,
  you should implement the following analysis functions:
  - `productive (s : syntax) : bool`
    determines whether there exists a word that `s` accepts
    ([Section 4.1](https://arxiv.org/pdf/1911.12737)).
  - `nullable (s : syntax) : bool`
    determines whether `s` accepts the empty word
    ([Section 4.2](https://arxiv.org/pdf/1911.12737)).
  - `first (s : syntax) : kinds`
    computes the set of the token kinds `k`
    such that at least one word that is accepted by `s`
    begins with a token of kind `k`
    ([Section 4.3](https://arxiv.org/pdf/1911.12737)).
  - `should_not_follow (s : syntax) : kinds`
    computes the set of the token kinds `k`
    such that a word that is accepted by `s`
    should not be followed with a token of kind `k`
    ([Section 4.4](https://arxiv.org/pdf/1911.12737)).
  - `has_conflict (s : syntax) : bool`
    determines whether the syntax `s` has an LL(1) conflict,
    as defined in [Section 4.5](https://arxiv.org/pdf/1911.12737)
    of the paper.
    A syntax is in the class LL(1) if it has no conflict.

  Then, following Section 5 of the paper,
  you can implement a simple (inefficient) recognition algorithm,
  based on derivatives.
  - Define `derivative : token -> syntax -> syntax`
    ([Section 5.1](https://arxiv.org/pdf/1911.12737)).
  - Define `parse : syntax -> token list -> bool`
    as repeated derivation
    followed with a call to `nullable`
    ([Section 5.2](https://arxiv.org/pdf/1911.12737)).

  Then, you may go on with [Section 6](https://arxiv.org/pdf/1911.12737)
  and write an efficient recognizer.
  - Define the type `context`
    as a stack of layers
    ([Section 6.2](https://arxiv.org/pdf/1911.12737)).
    At this stage,
    because you do not have semantic values yet,
    the constructors `apply` and `prepend` mentioned in the paper are not needed.
  - Define the type `focus`
    as an abbreviation for `context * syntax`.
  - Define `pierce : token -> focus -> focus`,
    a variant of the function `derivative`,
    which operates on *focused syntaxes*
    ([Section 6.3](https://arxiv.org/pdf/1911.12737)).
    In short, `pierce tok (c, s)` assumes that `kind tok` is in the set `first s` and moves
    the focus *down* to the subtree of `s` that is willing to consume the token `tok`.
  - Define `locate : token -> focus -> focus option`
    ([Section 6.3](https://arxiv.org/pdf/1911.12737)).
    In short, `locate tok (c, s)` tests whether `kind tok` is in the set `first s`.
    If so, `locate` does nothing.
    Otherwise, the syntax `s` must be nullable (i.e., accept the empty string);
    then `locate` moves the focus *back up* in the context so as to find
    a piece of syntax that follows `s` and can consume the token `tok`.
    If the input is ill-formed, this can fail.
  - Define `parse` as repeated derivation, performed by `locate` and `pierce`
    ([Sections 6.3 and 6.4](https://arxiv.org/pdf/1911.12737)).

* In the second stage, move from a recognizer,
  which produces a result of type `bool`,
  to a parser,
  which produces a semantic value of type `'a`.
  - The type `'a syntax` is now parameterized,
    and is a GADT.
  - The combinator `map` is re-introduced.
  - The type `context` is also parameterized,
    and is a GADT.
    Its constructors are described in [Section 6.2](https://arxiv.org/pdf/1911.12737).
  - Every function must be revisited.

* In the third stage,
  introduce support for recursive definitions,
  that is, for the combinator `declare`.

  The main difficulty in this stage is that an object of type `'a syntax`
  should no longer be an abstract syntax *tree*: instead it should be a
  *graph*, where sharing and cycles are permitted. (By *sharing*, we mean
  that a node can have more than one parent node.)

  Therefore you should
  - Modify the type `'a syntax` so that every node carries a unique *identifier*
    (a number) and a *description* of this node (e.g., the empty word, a sequence,
    an alternative, etc.).
  - Introduce a separate (generalized) algebraic data type `'a desc` of descriptions.
    The types `'a syntax` and `'a desc` are mutually recursive.
  - Allow creating a new node (and choosing its identifier) without
    providing a description of this node. Allow later providing
    a description of this node as a separate operation.
    This is needed by `declare`.
  - Every function must be revisited. In particular,
    the analysis functions of [Section 4](https://arxiv.org/pdf/1911.12737)
    must now be prepared to work on a cyclic graph,
    as opposed to a tree.
    Therefore, they cannot be defined using `let rec`.
    A least fixed point computation is needed.
    The library [fix](https://cambium.inria.fr/~fpottier/fix/doc/fix/Fix/Fix/index.html)
    may be used for this purpose. The unique identifiers carried by graph nodes
    must be exploited.

## Suggested Extensions

*For fun*, it is possible to implement more features than those requested above.

These extra features do *not* grant extra credit.
Implementing what is requested above,
without extra features,
is sufficient to achieve the maximum grade (20/20).

Here are some suggestions of extra features:

* Explain LL(1) conflicts (at analysis time),
  so as to help the user modify their grammar
  and avoid the conflict.

* When an invalid input is detected (at runtime),
  point out the location of the syntax error,
  and explain the error:
  what is the current state of the parser
  (what has it understood so far)?
  what does it expect next?

## Reporting issues and asking for help

This programming project assumes a certain level of general knowledge about
context-free languages and familiarity with algorithms on trees and graphs.
**Please do not hesitate to ask questions, to request clarifications, and to
report problems in the task description.** Please do so publicly by [opening
an issue](https://github.com/fpottier/mpri-fun-zippy-parsing/issues) in the
repository of the project skeleton. We will then answer publicly.

## Plagiarism and AI policy

You are expected to carry out this project alone and without the help of
generative AI. The code that you submit should be written by you, by hand.

It is permitted to *discuss* the project, including problems and solutions,
with other students. It is *not* permitted to copy and paste another student's
solution.

It is permitted to use a traditional editing environment with limited
generation capabilities, such as an auto-completion facility for variable
names, or a spell-checker. It is *not* permitted to use LLM-based tools
that have the ability of writing a complete solution.

<!--
# LocalWords:  combinators combinator bool toks nullable prepend syntaxes tok
# LocalWords:  subtree GADT desc OCaml Romain Edelmann Jad Hamza Viktor cd rf
# LocalWords:  Kunčak mpri init Makefile src lexbuf lexing OCaml's runtest md
# LocalWords:  François
-->
