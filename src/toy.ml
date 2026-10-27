type var =
  string

type vars =
  var list

type addop =
  | Add
  | Sub

type mulop =
  | Mul
  | Div

type expr =
  | EVar of string
  | EIntLiteral of int
  | EAddOp of expr * addop * expr
  | EMulOp of expr * mulop * expr
  | ELet of var * expr * expr
  | ESum of var * expr * expr * expr
  | EFun of vars * expr
  | EApp of var * exprs

and exprs =
  expr list

type ty =
  | TyInt
  | TyFun of tys * ty

and tys =
  ty list

(* Constructors for n-ary additive and multiplicative expressions. *)

let rec iterated_add accu tail =
  match tail with
  | [] ->
      accu
  | (op, head) :: tail ->
      let accu = EAddOp (accu, op, head) in
      iterated_add accu tail

let rec iterated_mul accu tail =
  match tail with
  | [] ->
      accu
  | (op, head) :: tail ->
      let accu = EMulOp (accu, op, head) in
      iterated_mul accu tail
