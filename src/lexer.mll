{

open Printf
open Lexing

let[@inline] filename (startp, _endp) =
  startp.pos_fname

let[@inline] linenum (startp, _endp) =
  startp.pos_lnum

let[@inline] linecount (startp, endp) =
  endp.pos_lnum - startp.pos_lnum

let[@inline] column (startp, _endp) =
  startp.pos_cnum - startp.pos_bol

let[@inline] end_column (startp, endp) =
  endp.pos_cnum - startp.pos_bol (* intentionally [startp.pos_bol] *)

(* [show range] prints a range (a pair of positions). *)

let show range =
  sprintf
    "File \"%s\", line %d, characters %d-%d"
    (filename range) (linenum range)
    (column range) (end_column range)

(* [blame range format ...] reports an error at [range]. *)

let die _f =
  exit 1

let current lexbuf =
  (lexeme_start_p lexbuf, lexeme_end_p lexbuf)

let error lexbuf format =
  let format = "Error: " ^^ format ^^ "\n%!" in
  let range = current lexbuf in
  fprintf stderr "%s:\n" (show range);
  kfprintf die stderr format

let int_of_string lexbuf i =
  try
    int_of_string i
  with Failure _ ->
    error lexbuf "unreasonably large integer."

open Token

}

let newline = ('\010' | '\013' | "\013\010")

let whitespace = [ ' ' '\t' ]

let lowercase = ['a'-'z' '\223'-'\246' '\248'-'\255' '_']

let identchar = ['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '0'-'9'] (* '\'' forbidden *)

let number =  ['0'-'9']+

let identifier =
  lowercase identchar*

rule main = parse
| ","
    { COMMA }
| "("
    { LPAREN }
| ")"
    { RPAREN }
| "+"
    { ADD }
| "-"
    { SUB }
| "*"
    { MUL }
| "/"
    { DIV }
| "let"
    { LET }
| "="
    { EQ }
| "in"
    { IN }
| "for"
    { FOR }
| "from"
    { FROM }
| "to"
    { TO }
| "sum"
    { SUM }
| "fun"
    { FUN }
| "->"
    { ARROW }
| number as i
    { INT (int_of_string lexbuf i) }
| identifier as id
    { ID id }
| newline
    { new_line lexbuf; main lexbuf }
| whitespace+
    { main lexbuf }
| eof
    { EOF }
| _ as c
    { error lexbuf "unexpected character: '%c'." c }
