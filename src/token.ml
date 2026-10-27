type token =
| COMMA
| LPAREN
| RPAREN
| ADD
| SUB
| MUL
| DIV
| LET
| EQ
| IN
| FOR
| FROM
| TO
| SUM
| FUN
| ARROW
| EOF
| INT of int
| ID of string

type kind =
| KCOMMA
| KLPAREN
| KRPAREN
| KADD
| KSUB
| KMUL
| KDIV
| KLET
| KEQ
| KIN
| KFOR
| KFROM
| KTO
| KSUM
| KFUN
| KARROW
| KEOF
| KINT
| KID

let kind (tok : token) : kind =
  match tok with
  | COMMA -> KCOMMA
  | LPAREN -> KLPAREN
  | RPAREN -> KRPAREN
  | ADD -> KADD
  | SUB -> KSUB
  | MUL -> KMUL
  | DIV -> KDIV
  | LET -> KLET
  | EQ -> KEQ
  | IN -> KIN
  | FOR -> KFOR
  | FROM -> KFROM
  | TO -> KTO
  | SUM -> KSUM
  | FUN -> KFUN
  | ARROW -> KARROW
  | EOF -> KEOF
  | INT _ -> KINT
  | ID _ -> KID

type t =
  kind

let compare : t -> t -> int =
  Stdlib.compare

let unID (tok : token) : string =
  match tok with
  | ID x -> x
  | _    -> assert false

let unINT (tok : token) : int =
  match tok with
  | INT i -> i
  | _     -> assert false

let is_eof (tok : token) : bool =
  match tok with
  | EOF -> true
  | _   -> false
