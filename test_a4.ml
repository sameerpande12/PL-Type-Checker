
#load "a0.cmo";;
#load "a1.cmo";;
#load "a2.cmo";;
#load "a3.cmo";;
#load "a4.cmo";;
open A0;;
open A1;;
open A2;;
open A3;;
open A4;;

exception Not_implemented
(* Helper function to print *)
let rec print_tree tr = match tr with
  N a -> "INT " ^ (string_of_int a)
  | _ -> raise Not_implemented
;;
let rec print_answer tr = match tr with
  Num a -> print_num a
  | Bool a -> string_of_bool a
  | _ -> raise Not_implemented
;;
let rec print_value tr = match tr with
  NumVal a -> string_of_int a
  | BoolVal a -> string_of_bool a
  | _ -> raise Not_implemented
;;
let rec print_def df = match df with
    Simple((l,ltype),r) -> "def " ^ l ^ " = " ^ (print_tree r)
  | _ -> raise Not_implemented
;;


(* Input is given as value and output is an answer *)
let rec toAnswer v = match v with
  NumVal a     -> Num (mk_big a)
| BoolVal b    -> Bool b
| TupVal (n,xs) -> Tup (n, List.map toAnswer xs);;

(* Input is given as string and output is an answer *)
let binding rho s = toAnswer (rho s);;

(* Both use the same lexer in A1 but different parser in A3 *)
let exp_parser s rho = A3.exp_parser A2.read (Lexing.from_string s) ;;
let def_parser s rho = A3.def_parser A2.read (Lexing.from_string s) ;;
let type_parser s rho = A3.type_parser A2.read (Lexing.from_string s) ;;
let scan s = A2.read (Lexing.from_string s);;
(* Input is given as string and output is a value *)
let rho s = match s with
  "X" -> NumVal 5
  |  "Y" -> BoolVal true
  |  "Z" -> TupVal (3, [NumVal 5; BoolVal true; NumVal 1])
  | _ -> raise Not_implemented
;;


(* Sample parsing *)
print_endline ( print_tree (exp_parser "5" rho));;
print_endline ( print_def (def_parser "def a=5" rho));;

(* Sample test case *)
let e = (exp_parser "\\X:Tint.Y" rho);;
let t = Tfunc (Tint, Tbool);;

(* Type assumptions as a list of tuples of the form (variable name, type) *)
let g = [ ("X", Tint); ("Y", Tbool); ("Z", Ttuple [Tint ; Tbool ; Tint]); ("W", Tfunc (Tint, Tbool))];;
let d = (def_parser "def U:Tint = X ; def V:Tbool = Y" rho);;
let g_dash = [("U", Tint); ("V", Tbool)];;

let parse s = exp_parser s rho;;
let srd myv = A2.read (Lexing.from_string myv);;



(hastype g e t);;
(yields g d g_dash);;


let d = (def_parser "def U = X ; def V = Y" rho);;
let g_dash = [("U", Tbool); ("V", Tbool)];;
(yields g d g_dash);;


let d = (def_parser "def U = 3 || def U = T ; def V = Y" rho);;
let g_dash = [("U", Tint); ("V", Tbool)];;
(yields g d g_dash);;(*should give false because of type error due to parallel definition*)


let d = (def_parser " local def X = 4 in def Y = X end " rho);;
let g_dash = [("Y",Tint)];;
yields g d g_dash;;
let g_dash = [("X",Tint);("Y",Tint)];;


let e = (exp_parser "let def Y=\\X.(X) in Y(5) end" rho);;
let g = [("X",Tint)];;
