module Make (T : sig

  (**A token is a concrete input symbol. *)
  type token

  (**A kind is a family of input symbols that one wishes to regard
     as a single abstract input symbol. *)
  type kind

  (**The function [kind] maps an input symbol to its kind. *)
  val kind : token -> kind

  (**A total order on kinds is needed. *)
  include Set.OrderedType with type t = kind

end) : sig

  open T

  (* {1 Combinators} *)

  (**A value of type ['a syntax] describes a context-free language, that is,
     a certain set of words that are considered valid or well-formed. (A
     word is a sequence of tokens.) At the same time, it describes a way of
     converting every well-formed word to a value of type ['a]. Such a value
     is sometimes called a {i semantic value}.

     A description [s : 'a syntax] is interpreted (executed) via a function
     call of the form [parse s toks], where [toks] is a sequence of tokens.
     This call either rejects the word [toks] and returns [None] or accepts
     this word and returns [Some v], where [v : 'a] is a semantic value. *)
  type 'a syntax

  (**[literal k] recognizes a token of the kind [k] and returns it. *)
  val literal : kind -> token syntax

  (**[fail] recognizes nothing. *)
  val fail : unit -> 'a syntax

  (**[epsilon] recognizes the empty word. *)
  val epsilon : 'a -> 'a syntax

  (**[alt s1 s2] is an alternative between [s1] and [s2]. It recognizes
     a word that is recognized by [s1] or by [s2]. *)
  val alt : 'a syntax -> 'a syntax -> 'a syntax

  (**[seq s1 s2] is the sequential composition of [s1] and [s2]. It
     recognizes a word that is recognized by [s1], followed with a word that
     is recognized by [s2]. *)
  val seq : 'a syntax -> 'b syntax -> ('a * 'b) syntax

  (**[map s f] recognizes a word that is recognized by [s], then applies the
     transformation [f] to its semantic value. The OCaml function [f] is
     sometimes called a {i semantic action}. *)
  val map : 'a syntax -> ('a -> 'b) -> 'b syntax

  (**[choose ss] is a multi-way alternative. It recognizes a word that is
     recognized by one of the syntaxes in the list [ss]. *)
  val choose : 'a syntax list -> 'a syntax

  (**[maybe s] is an option, a two-way alternative. It recognizes either a
     word that is recognized by [s] or the empty word. *)
  val maybe : 'a syntax -> 'a option syntax

  (**[star s] describes a list of [s]'s. It recognizes a sequence of zero,
     one, or several words that are recognized by [s]. *)
  val star : 'a syntax -> 'a list syntax

  (**[fix (fun x -> s)] recognizes the context-free language described by
     the non-terminal symbol [x] together with the production [x := s].
     The syntax [s] may recursively refer to [x]. *)
  val fix : ('a syntax -> 'a syntax) -> 'a syntax

  (**[declare()] returns a pair [x, define] where [x] is a new non-terminal
     symbol and where [define (fun () -> s)] must be called once to equip
     this symbol with the production [x := s].

     If [define] is called more than once then an exception is raised by
     [define]. If [define] is never called then an exception is raised by
     {!is_LL1} or by {!parse}.

     This mechanism is more expressive than {!fix}, as it allows defining
     several mutually recursive non-terminal symbols. *)
  val declare : unit -> 'a syntax * ((unit -> 'a syntax) -> unit)

  (* {1 Analysis} *)

  (**[is_LL1 s] determines whether the language described by [s]
     belongs in the class LL(1). *)
  val is_LL1 : 'a syntax -> bool

  (* {1 Execution} *)

  (**[parse s toks] determines whether the word [toks] is recognized by the
     syntax [s]. If it is, [Some v] is returned, where [v] is the
     corresponding semantic value. Otherwise, [None] is returned. The syntax
     [s] must lie in the class LL(1); that is, [is_LL1 s] must be true. *)
  val parse : 'a syntax -> token list -> 'a option

end
