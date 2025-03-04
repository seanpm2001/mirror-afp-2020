structure exported : sig
  type num
  type int
  type nat
  val integer_of_nat : nat -> IntInf.int
  type char
  datatype ('a, 'b) sum = Inl of 'a | Inr of 'b
  val integer_of_int : int -> IntInf.int
  val nat : int -> nat
  val concat : ('a list) list -> 'a list
  val implode : char list -> string
  val size_list : 'a list -> nat
  val int_of_integer : IntInf.int -> int
  val encode :
    nat ->
      (char list * (nat option * (char list) list)) list *
        (nat list *
          ((nat * nat) list *
            (char list *
              ((nat * nat) list *
                (((nat * nat) list * (nat * (nat option * nat))) list *
                  nat))) list)) ->
        (((int list) list), string) sum
  val max_var : int list -> int
  val explode : string -> char list
  val nat_of_integer : IntInf.int -> nat
  val char_of_nat : nat -> char
  val nat_opt_of_integer : IntInf.int -> nat option
end = struct

datatype num = One | Bit0 of num | Bit1 of num;

datatype int = Zero_int | Pos of num | Neg of num;

val one_inta : int = Pos One;

type 'a one = {one : 'a};
val one = #one : 'a one -> 'a;

val one_int = {one = one_inta} : int one;

type 'a zero = {zero : 'a};
val zero = #zero : 'a zero -> 'a;

val zero_int = {zero = Zero_int} : int zero;

type 'a zero_neq_one = {one_zero_neq_one : 'a one, zero_zero_neq_one : 'a zero};
val one_zero_neq_one = #one_zero_neq_one : 'a zero_neq_one -> 'a one;
val zero_zero_neq_one = #zero_zero_neq_one : 'a zero_neq_one -> 'a zero;

val zero_neq_one_int =
  {one_zero_neq_one = one_int, zero_zero_neq_one = zero_int} : int zero_neq_one;

datatype nat = Nat of IntInf.int;

fun integer_of_nat (Nat x) = x;

fun equal_nata m n = (((integer_of_nat m) : IntInf.int) = (integer_of_nat n));

type 'a equal = {equal : 'a -> 'a -> bool};
val equal = #equal : 'a equal -> 'a -> 'a -> bool;

val equal_nat = {equal = equal_nata} : nat equal;

fun eq A_ a b = equal A_ a b;

fun equal_lista A_ [] (x21 :: x22) = false
  | equal_lista A_ (x21 :: x22) [] = false
  | equal_lista A_ (x21 :: x22) (y21 :: y22) =
    eq A_ x21 y21 andalso equal_lista A_ x22 y22
  | equal_lista A_ [] [] = true;

fun equal_list A_ = {equal = equal_lista A_} : ('a list) equal;

fun equal_bool p true = p
  | equal_bool p false = not p
  | equal_bool true p = p
  | equal_bool false p = not p;

datatype char = Chara of bool * bool * bool * bool * bool * bool * bool * bool;

fun equal_chara (Chara (x1, x2, x3, x4, x5, x6, x7, x8))
  (Chara (y1, y2, y3, y4, y5, y6, y7, y8)) =
  equal_bool x1 y1 andalso
    (equal_bool x2 y2 andalso
      (equal_bool x3 y3 andalso
        (equal_bool x4 y4 andalso
          (equal_bool x5 y5 andalso
            (equal_bool x6 y6 andalso
              (equal_bool x7 y7 andalso equal_bool x8 y8))))));

val equal_char = {equal = equal_chara} : char equal;

fun equal_proda A_ B_ (x1, x2) (y1, y2) = eq A_ x1 y1 andalso eq B_ x2 y2;

fun equal_prod A_ B_ = {equal = equal_proda A_ B_} : ('a * 'b) equal;

fun equal_unita u v = true;

val equal_unit = {equal = equal_unita} : unit equal;

val one_integera : IntInf.int = (1 : IntInf.int);

val one_integer = {one = one_integera} : IntInf.int one;

val zero_integer = {zero = (0 : IntInf.int)} : IntInf.int zero;

type 'a ord = {less_eq : 'a -> 'a -> bool, less : 'a -> 'a -> bool};
val less_eq = #less_eq : 'a ord -> 'a -> 'a -> bool;
val less = #less : 'a ord -> 'a -> 'a -> bool;

val ord_integer =
  {less_eq = (fn a => fn b => IntInf.<= (a, b)),
    less = (fn a => fn b => IntInf.< (a, b))}
  : IntInf.int ord;

val zero_neq_one_integer =
  {one_zero_neq_one = one_integer, zero_zero_neq_one = zero_integer} :
  IntInf.int zero_neq_one;

datatype ('a, 'b) strips_operator_ext =
  Strips_operator_ext of 'a list * 'a list * 'a list * 'b;

fun equal_strips_operator_exta A_ B_
  (Strips_operator_ext
    (precondition_ofa, add_effects_ofa, delete_effects_ofa, morea))
  (Strips_operator_ext
    (precondition_of, add_effects_of, delete_effects_of, more))
  = equal_lista A_ precondition_ofa precondition_of andalso
      (equal_lista A_ add_effects_ofa add_effects_of andalso
        (equal_lista A_ delete_effects_ofa delete_effects_of andalso
          eq B_ morea more));

fun equal_strips_operator_ext A_ B_ = {equal = equal_strips_operator_exta A_ B_}
  : ('a, 'b) strips_operator_ext equal;

datatype ('a, 'b) sum = Inl of 'a | Inr of 'b;

datatype 'a formula = Atom of 'a | Bot | Not of 'a formula |
  And of 'a formula * 'a formula | Or of 'a formula * 'a formula |
  Imp of 'a formula * 'a formula;

datatype sat_plan_variable = State of nat * nat | Operator of nat * nat;

datatype ('a, 'b) strips_problem_ext =
  Strips_problem_ext of
    'a list * ('a, unit) strips_operator_ext list * ('a -> bool option) *
      ('a -> bool option) * 'b;

datatype ('a, 'b, 'c) sas_plus_operator_ext =
  Sas_plus_operator_ext of ('a * 'b) list * ('a * 'b) list * 'c;

datatype ('a, 'b, 'c) sas_plus_problem_ext =
  Sas_plus_problem_ext of
    'a list * ('a, 'b, unit) sas_plus_operator_ext list * ('a -> 'b option) *
      ('a -> 'b option) * ('a -> ('b list) option) * 'c;

fun id x = (fn xa => xa) x;

fun dup (Neg n) = Neg (Bit0 n)
  | dup (Pos n) = Pos (Bit0 n)
  | dup Zero_int = Zero_int;

fun plus_num (Bit1 m) (Bit1 n) = Bit0 (plus_num (plus_num m n) One)
  | plus_num (Bit1 m) (Bit0 n) = Bit1 (plus_num m n)
  | plus_num (Bit1 m) One = Bit0 (plus_num m One)
  | plus_num (Bit0 m) (Bit1 n) = Bit1 (plus_num m n)
  | plus_num (Bit0 m) (Bit0 n) = Bit0 (plus_num m n)
  | plus_num (Bit0 m) One = Bit1 m
  | plus_num One (Bit1 n) = Bit0 (plus_num n One)
  | plus_num One (Bit0 n) = Bit1 n
  | plus_num One One = Bit0 One;

fun times_num (Bit1 m) (Bit1 n) =
  Bit1 (plus_num (plus_num m n) (Bit0 (times_num m n)))
  | times_num (Bit1 m) (Bit0 n) = Bit0 (times_num (Bit1 m) n)
  | times_num (Bit0 m) (Bit1 n) = Bit0 (times_num m (Bit1 n))
  | times_num (Bit0 m) (Bit0 n) = Bit0 (Bit0 (times_num m n))
  | times_num One n = n
  | times_num m One = m;

fun times_int (Neg m) (Neg n) = Pos (times_num m n)
  | times_int (Neg m) (Pos n) = Neg (times_num m n)
  | times_int (Pos m) (Neg n) = Neg (times_num m n)
  | times_int (Pos m) (Pos n) = Pos (times_num m n)
  | times_int Zero_int l = Zero_int
  | times_int k Zero_int = Zero_int;

fun less_eq_num (Bit1 m) (Bit0 n) = less_num m n
  | less_eq_num (Bit1 m) (Bit1 n) = less_eq_num m n
  | less_eq_num (Bit0 m) (Bit1 n) = less_eq_num m n
  | less_eq_num (Bit0 m) (Bit0 n) = less_eq_num m n
  | less_eq_num (Bit1 m) One = false
  | less_eq_num (Bit0 m) One = false
  | less_eq_num One n = true
and less_num (Bit1 m) (Bit0 n) = less_num m n
  | less_num (Bit1 m) (Bit1 n) = less_num m n
  | less_num (Bit0 m) (Bit1 n) = less_eq_num m n
  | less_num (Bit0 m) (Bit0 n) = less_num m n
  | less_num One (Bit1 n) = true
  | less_num One (Bit0 n) = true
  | less_num m One = false;

fun less_eq_int (Neg k) (Neg l) = less_eq_num l k
  | less_eq_int (Neg k) (Pos l) = true
  | less_eq_int (Neg k) Zero_int = true
  | less_eq_int (Pos k) (Neg l) = false
  | less_eq_int (Pos k) (Pos l) = less_eq_num k l
  | less_eq_int (Pos k) Zero_int = false
  | less_eq_int Zero_int (Neg l) = false
  | less_eq_int Zero_int (Pos l) = true
  | less_eq_int Zero_int Zero_int = true;

fun uminus_int (Neg m) = Pos m
  | uminus_int (Pos m) = Neg m
  | uminus_int Zero_int = Zero_int;

fun bitM One = One
  | bitM (Bit0 n) = Bit1 (bitM n)
  | bitM (Bit1 n) = Bit1 (Bit0 n);

fun minus_int (Neg m) (Neg n) = sub n m
  | minus_int (Neg m) (Pos n) = Neg (plus_num m n)
  | minus_int (Pos m) (Neg n) = Pos (plus_num m n)
  | minus_int (Pos m) (Pos n) = sub m n
  | minus_int Zero_int l = uminus_int l
  | minus_int k Zero_int = k
and sub (Bit0 m) (Bit1 n) = minus_int (dup (sub m n)) one_inta
  | sub (Bit1 m) (Bit0 n) = plus_int (dup (sub m n)) one_inta
  | sub (Bit1 m) (Bit1 n) = dup (sub m n)
  | sub (Bit0 m) (Bit0 n) = dup (sub m n)
  | sub One (Bit1 n) = Neg (Bit0 n)
  | sub One (Bit0 n) = Neg (bitM n)
  | sub (Bit1 m) One = Pos (Bit0 m)
  | sub (Bit0 m) One = Pos (bitM m)
  | sub One One = Zero_int
and plus_int (Neg m) (Neg n) = Neg (plus_num m n)
  | plus_int (Neg m) (Pos n) = sub n m
  | plus_int (Pos m) (Neg n) = sub m n
  | plus_int (Pos m) (Pos n) = Pos (plus_num m n)
  | plus_int Zero_int l = l
  | plus_int k Zero_int = k;

fun divmod_step_int l (q, r) =
  (if less_eq_int (Pos l) r
    then (plus_int (times_int (Pos (Bit0 One)) q) one_inta, minus_int r (Pos l))
    else (times_int (Pos (Bit0 One)) q, r));

fun divmod_int (Bit1 m) (Bit1 n) =
  (if less_num m n then (Zero_int, Pos (Bit1 m))
    else divmod_step_int (Bit1 n) (divmod_int (Bit1 m) (Bit0 (Bit1 n))))
  | divmod_int (Bit0 m) (Bit1 n) =
    (if less_eq_num m n then (Zero_int, Pos (Bit0 m))
      else divmod_step_int (Bit1 n) (divmod_int (Bit0 m) (Bit0 (Bit1 n))))
  | divmod_int (Bit1 m) (Bit0 n) =
    let
      val (q, r) = divmod_int m n;
    in
      (q, plus_int (times_int (Pos (Bit0 One)) r) one_inta)
    end
  | divmod_int (Bit0 m) (Bit0 n) = let
                                     val (q, r) = divmod_int m n;
                                   in
                                     (q, times_int (Pos (Bit0 One)) r)
                                   end
  | divmod_int One (Bit1 n) = (Zero_int, Pos One)
  | divmod_int One (Bit0 n) = (Zero_int, Pos One)
  | divmod_int (Bit1 m) One = (Pos (Bit1 m), Zero_int)
  | divmod_int (Bit0 m) One = (Pos (Bit0 m), Zero_int)
  | divmod_int One One = (Pos One, Zero_int);

fun snd (x1, x2) = x2;

fun equal_num (Bit0 x2) (Bit1 x3) = false
  | equal_num (Bit1 x3) (Bit0 x2) = false
  | equal_num One (Bit1 x3) = false
  | equal_num (Bit1 x3) One = false
  | equal_num One (Bit0 x2) = false
  | equal_num (Bit0 x2) One = false
  | equal_num (Bit1 x3) (Bit1 y3) = equal_num x3 y3
  | equal_num (Bit0 x2) (Bit0 y2) = equal_num x2 y2
  | equal_num One One = true;

fun equal_int (Neg k) (Neg l) = equal_num k l
  | equal_int (Neg k) (Pos l) = false
  | equal_int (Neg k) Zero_int = false
  | equal_int (Pos k) (Neg l) = false
  | equal_int (Pos k) (Pos l) = equal_num k l
  | equal_int (Pos k) Zero_int = false
  | equal_int Zero_int (Neg l) = false
  | equal_int Zero_int (Pos l) = false
  | equal_int Zero_int Zero_int = true;

fun adjust_mod l r = (if equal_int r Zero_int then Zero_int else minus_int l r);

fun modulo_int (Neg m) (Neg n) = uminus_int (snd (divmod_int m n))
  | modulo_int (Pos m) (Neg n) =
    uminus_int (adjust_mod (Pos n) (snd (divmod_int m n)))
  | modulo_int (Neg m) (Pos n) = adjust_mod (Pos n) (snd (divmod_int m n))
  | modulo_int (Pos m) (Pos n) = snd (divmod_int m n)
  | modulo_int k (Neg One) = Zero_int
  | modulo_int k (Pos One) = Zero_int
  | modulo_int Zero_int k = Zero_int
  | modulo_int k Zero_int = k;

fun fst (x1, x2) = x1;

fun of_bool A_ true = one (one_zero_neq_one A_)
  | of_bool A_ false = zero (zero_zero_neq_one A_);

fun adjust_div (q, r) =
  plus_int q (of_bool zero_neq_one_int (not (equal_int r Zero_int)));

fun divide_int (Neg m) (Neg n) = fst (divmod_int m n)
  | divide_int (Pos m) (Neg n) = uminus_int (adjust_div (divmod_int m n))
  | divide_int (Neg m) (Pos n) = uminus_int (adjust_div (divmod_int m n))
  | divide_int (Pos m) (Pos n) = fst (divmod_int m n)
  | divide_int k (Neg One) = uminus_int k
  | divide_int k (Pos One) = k
  | divide_int Zero_int k = Zero_int
  | divide_int k Zero_int = Zero_int;

fun less_int (Neg k) (Neg l) = less_num l k
  | less_int (Neg k) (Pos l) = true
  | less_int (Neg k) Zero_int = true
  | less_int (Pos k) (Neg l) = false
  | less_int (Pos k) (Pos l) = less_num k l
  | less_int (Pos k) Zero_int = false
  | less_int Zero_int (Neg l) = false
  | less_int Zero_int (Pos l) = true
  | less_int Zero_int Zero_int = false;

fun integer_of_int k =
  (if less_int k Zero_int then IntInf.~ (integer_of_int (uminus_int k))
    else (if equal_int k Zero_int then (0 : IntInf.int)
           else let
                  val l =
                    IntInf.* ((2 : IntInf.int), integer_of_int
          (divide_int k (Pos (Bit0 One))));
                  val j = modulo_int k (Pos (Bit0 One));
                in
                  (if equal_int j Zero_int then l
                    else IntInf.+ (l, (1 : IntInf.int)))
                end));

fun max A_ a b = (if less_eq A_ a b then b else a);

fun nat k = Nat (max ord_integer (0 : IntInf.int) (integer_of_int k));

fun plus_nat m n = Nat (IntInf.+ (integer_of_nat m, integer_of_nat n));

val one_nat : nat = Nat (1 : IntInf.int);

fun suc n = plus_nat n one_nat;

fun minus_nat m n =
  Nat (max ord_integer (0 : IntInf.int)
        (IntInf.- (integer_of_nat m, integer_of_nat n)));

val zero_nat : nat = Nat (0 : IntInf.int);

fun nth (x :: xs) n =
  (if equal_nata n zero_nat then x else nth xs (minus_nat n one_nat));

fun less_nat m n = IntInf.< (integer_of_nat m, integer_of_nat n);

fun upt i j = (if less_nat i j then i :: upt (suc i) j else []);

fun zip (x :: xs) (y :: ys) = (x, y) :: zip xs ys
  | zip xs [] = []
  | zip [] ys = [];

fun fold f (x :: xs) s = fold f xs (f x s)
  | fold f [] s = s;

fun maps f [] = []
  | maps f (x :: xs) = f x @ maps f xs;

fun null [] = true
  | null (x :: xs) = false;

fun foldr f [] = id
  | foldr f (x :: xs) = f x o foldr f xs;

fun map_of A_ ((l, v) :: ps) k = (if eq A_ l k then SOME v else map_of A_ ps k)
  | map_of A_ [] k = NONE;

fun concat xss = foldr (fn a => fn b => a @ b) xss [];

fun filter p [] = []
  | filter p (x :: xs) = (if p x then x :: filter p xs else filter p xs);

fun member A_ [] y = false
  | member A_ (x :: xs) y = eq A_ x y orelse member A_ xs y;

fun listMem A_ xa (x :: xs) = eq A_ xa x orelse listMem A_ xa xs
  | listMem A_ x [] = false;

fun list_ex p [] = false
  | list_ex p (x :: xs) = p x orelse list_ex p xs;

fun map f [] = []
  | map f (x21 :: x22) = f x21 :: map f x22;

fun product [] uu = []
  | product (x :: xs) ys = map (fn a => (x, a)) ys @ product xs ys;

fun distinct A_ [] = true
  | distinct A_ (x :: xs) = not (member A_ xs x) andalso distinct A_ xs;

fun bigOr [] = Bot
  | bigOr (f :: fs) = Or (f, bigOr fs);

fun is_none (SOME x) = false
  | is_none NONE = true;

fun integer_of_char (Chara (b0, b1, b2, b3, b4, b5, b6, b7)) =
  IntInf.+ (IntInf.* (IntInf.+ (IntInf.* (IntInf.+ (IntInf.* (IntInf.+ (IntInf.* (IntInf.+ (IntInf.* (IntInf.+ (IntInf.* (IntInf.+ (IntInf.* (of_bool
                        zero_neq_one_integer
                        b7, (2 : IntInf.int)), of_bool zero_neq_one_integer
         b6), (2 : IntInf.int)), of_bool zero_neq_one_integer
                                   b5), (2 : IntInf.int)), of_bool
                     zero_neq_one_integer
                     b4), (2 : IntInf.int)), of_bool zero_neq_one_integer
       b3), (2 : IntInf.int)), of_bool zero_neq_one_integer
                                 b2), (2 : IntInf.int)), of_bool
                   zero_neq_one_integer
                   b1), (2 : IntInf.int)), of_bool zero_neq_one_integer b0);

fun implode cs =
  (String.implode
    o List.map (fn k => if 0 <= k andalso k < 128 then (Char.chr o IntInf.toInt) k else raise Fail "Non-ASCII character in literal"))
    (map integer_of_char cs);

fun bigAnd [] = Not Bot
  | bigAnd (f :: fs) = And (f, bigAnd fs);

fun gen_length n (x :: xs) = gen_length (suc n) xs
  | gen_length n [] = n;

fun map_filter f [] = []
  | map_filter f (x :: xs) =
    (case f x of NONE => map_filter f xs | SOME y => y :: map_filter f xs);

fun find_index uu [] = zero_nat
  | find_index p (x :: xs) =
    (if p x then zero_nat else plus_nat (find_index p xs) one_nat);

fun index A_ xs = (fn a => find_index (fn x => eq A_ x a) xs);

fun the (SOME x2) = x2;

fun is_standard_effect x = (fn (pre, (_, (_, _))) => null pre) x;

fun list_all p [] = true
  | list_all p (x :: xs) = p x andalso list_all p xs;

fun is_standard_operator x =
  (fn (_, (_, (effects, _))) => list_all is_standard_effect effects) x;

fun consistent_map_lists A_ xs1 xs2 =
  list_all
    (fn (x1, _) =>
      list_all (fn (y1, y2) => (if eq A_ x1 y1 then eq A_ x1 y2 else true)) xs2)
    xs1;

fun implicit_pres effs =
  map_filter
    (fn x =>
      (if let
            val (_, (_, (vpre, _))) = x;
          in
            not (is_none vpre)
          end
        then SOME let
                    val (_, (v, (vpre, _))) = x;
                  in
                    (v, the vpre)
                  end
        else NONE))
    effs;

fun consistent_pres_op opa =
  let
    val (_, (pres, (effs, _))) = opa;
  in
    distinct equal_nat (map fst (pres @ implicit_pres effs)) andalso
      consistent_map_lists equal_nat pres (implicit_pres effs)
  end;

fun astDom problem = let
                       val (d, (_, (_, _))) = problem;
                     in
                       d
                     end;

fun size_list x = gen_length zero_nat x;

fun numVars problem = size_list (astDom problem);

fun numVals problem x = size_list (snd (snd (nth (astDom problem) x)));

fun wf_partial_state problem ps =
  distinct equal_nat (map fst ps) andalso
    list_all
      (fn (x, v) =>
        less_nat x (numVars problem) andalso less_nat v (numVals problem x))
      ps;

fun wf_operator problem =
  (fn (_, (pres, (effs, _))) =>
    wf_partial_state problem pres andalso
      (distinct equal_nat (map (fn (_, (v, (_, _))) => v) effs) andalso
        list_all
          (fn (epres, (x, (vp, v))) =>
            wf_partial_state problem epres andalso
              (less_nat x (numVars problem) andalso
                (less_nat v (numVals problem x) andalso
                  (case vp of NONE => true
                    | SOME va => less_nat va (numVals problem x)))))
          effs));

fun ast_delta problem = let
                          val (_, (_, (_, delta))) = problem;
                        in
                          delta
                        end;

fun astI problem = let
                     val (_, (i, (_, _))) = problem;
                   in
                     i
                   end;

fun astG problem = let
                     val (_, (_, (g, _))) = problem;
                   in
                     g
                   end;

fun less_eq_nat m n = IntInf.<= (integer_of_nat m, integer_of_nat n);

fun all_interval_nat p i j =
  less_eq_nat j i orelse p i andalso all_interval_nat p (suc i) j;

fun well_formed problem =
  equal_nata (size_list (astI problem)) (numVars problem) andalso
    (all_interval_nat
       (fn x => less_nat (nth (astI problem) x) (numVals problem x)) zero_nat
       (numVars problem) andalso
      (wf_partial_state problem (astG problem) andalso
        (distinct (equal_list equal_char) (map fst (ast_delta problem)) andalso
          list_all (wf_operator problem) (ast_delta problem))));

fun rem_effect_implicit_pres (preconds, (v, (implicit_pre, eff))) =
  (preconds, (v, (NONE, eff)));

fun rem_implicit_pres (name, (preconds, (effects, cost))) =
  (name,
    (implicit_pres effects @ preconds,
      (map rem_effect_implicit_pres effects, cost)));

fun rem_implicit_pres_ops (vars, (init, (goal, ops))) =
  (vars, (init, (goal, map rem_implicit_pres ops)));

fun operators_of
  (Strips_problem_ext (variables_of, operators_of, initial_of, goal_of, more)) =
  operators_of;

fun encode_interfering_operator_pair_exclusion A_ pi k op_1 op_2 =
  let
    val ops = operators_of pi;
  in
    Or (Not (Atom (Operator
                    (k, index (equal_strips_operator_ext A_ equal_unit) ops
                          op_1))),
         Not (Atom (Operator
                     (k, index (equal_strips_operator_ext A_ equal_unit) ops
                           op_2))))
  end;

fun delete_effects_of
  (Strips_operator_ext
    (precondition_of, add_effects_of, delete_effects_of, more))
  = delete_effects_of;

fun precondition_of
  (Strips_operator_ext
    (precondition_of, add_effects_of, delete_effects_of, more))
  = precondition_of;

fun are_operators_interfering A_ op_1 op_2 =
  list_ex (fn v => list_ex (eq A_ v) (delete_effects_of op_1))
    (precondition_of op_2) orelse
    list_ex (fn v => list_ex (eq A_ v) (precondition_of op_1))
      (delete_effects_of op_2);

fun encode_interfering_operator_exclusion A_ pi t =
  let
    val ops = operators_of pi;
    val interfering =
      filter
        (fn (op_1, op_2) =>
          not (equal_nata
                (index (equal_strips_operator_ext A_ equal_unit) ops op_1)
                (index (equal_strips_operator_ext A_ equal_unit) ops
                  op_2)) andalso
            are_operators_interfering A_ op_1 op_2)
        (product ops ops);
  in
    foldr (fn a => fn b => And (a, b))
      (maps (fn (op_1, op_2) =>
              map (fn k =>
                    encode_interfering_operator_pair_exclusion A_ pi k op_1
                      op_2)
                (upt zero_nat t))
        interfering)
      (Not Bot)
  end;

fun add_effects_of
  (Strips_operator_ext
    (precondition_of, add_effects_of, delete_effects_of, more))
  = add_effects_of;

fun variables_of
  (Strips_problem_ext (variables_of, operators_of, initial_of, goal_of, more)) =
  variables_of;

fun encode_positive_transition_frame_axiom A_ pi t v =
  let
    val vs = variables_of pi;
    val ops = operators_of pi;
    val adding_operators =
      filter (fn opa => listMem A_ v (add_effects_of opa)) ops;
  in
    Or (Atom (State (t, index A_ vs v)),
         Or (Not (Atom (State (suc t, index A_ vs v))),
              bigOr (map (fn opa =>
                           Atom (Operator
                                  (t, index
(equal_strips_operator_ext A_ equal_unit) ops opa)))
                      adding_operators)))
  end;

fun encode_negative_transition_frame_axiom A_ pi t v =
  let
    val vs = variables_of pi;
    val ops = operators_of pi;
    val deleting_operators =
      filter (fn opa => listMem A_ v (delete_effects_of opa)) ops;
  in
    Or (Not (Atom (State (t, index A_ vs v))),
         Or (Atom (State (suc t, index A_ vs v)),
              bigOr (map (fn opa =>
                           Atom (Operator
                                  (t, index
(equal_strips_operator_ext A_ equal_unit) ops opa)))
                      deleting_operators)))
  end;

fun encode_all_frame_axioms A_ pi t =
  let
    val l = product (upt zero_nat t) (variables_of pi);
  in
    bigAnd
      (map (fn (a, b) => encode_negative_transition_frame_axiom A_ pi a b) l @
        map (fn (a, b) => encode_positive_transition_frame_axiom A_ pi a b) l)
  end;

fun initial_of
  (Strips_problem_ext (variables_of, operators_of, initial_of, goal_of, more)) =
  initial_of;

fun encode_state_variable t k v =
  (case v of SOME true => Atom (State (t, k))
    | SOME false => Not (Atom (State (t, k))));

fun encode_initial_state A_ pi =
  let
    val i = initial_of pi;
    val vs = variables_of pi;
  in
    bigAnd
      (map_filter
        (fn x =>
          (if not (is_none (i x))
            then SOME (Or (encode_state_variable zero_nat (index A_ vs x) (i x),
                            Bot))
            else NONE))
        vs)
  end;

fun goal_of
  (Strips_problem_ext (variables_of, operators_of, initial_of, goal_of, more)) =
  goal_of;

fun encode_goal_state A_ pi t =
  let
    val vs = variables_of pi;
    val g = goal_of pi;
  in
    bigAnd
      (map_filter
        (fn x =>
          (if not (is_none (g x))
            then SOME (Or (encode_state_variable t (index A_ vs x) (g x), Bot))
            else NONE))
        vs)
  end;

fun encode_operator_precondition A_ pi t opa =
  let
    val vs = variables_of pi;
    val ops = operators_of pi;
  in
    bigAnd
      (map (fn v =>
             Or (Not (Atom (Operator
                             (t, index (equal_strips_operator_ext A_ equal_unit)
                                   ops opa))),
                  Atom (State (t, index A_ vs v))))
        (precondition_of opa))
  end;

fun encode_all_operator_preconditions A_ pi ops t =
  let
    val l = product (upt zero_nat t) ops;
  in
    foldr ((fn a => fn b => And (a, b)) o
            (fn (a, b) => encode_operator_precondition A_ pi a b))
      l (Not Bot)
  end;

fun encode_operator_effect A_ pi t opa =
  let
    val vs = variables_of pi;
    val ops = operators_of pi;
  in
    bigAnd
      (map (fn v =>
             Or (Not (Atom (Operator
                             (t, index (equal_strips_operator_ext A_ equal_unit)
                                   ops opa))),
                  Atom (State (suc t, index A_ vs v))))
         (add_effects_of opa) @
        map (fn v =>
              Or (Not (Atom (Operator
                              (t, index (equal_strips_operator_ext A_
  equal_unit)
                                    ops opa))),
                   Not (Atom (State (suc t, index A_ vs v)))))
          (delete_effects_of opa))
  end;

fun encode_all_operator_effects A_ pi ops t =
  let
    val l = product (upt zero_nat t) ops;
  in
    foldr ((fn a => fn b => And (a, b)) o
            (fn (a, b) => encode_operator_effect A_ pi a b))
      l (Not Bot)
  end;

fun encode_operators A_ pi t =
  let
    val ops = operators_of pi;
  in
    And (encode_all_operator_preconditions A_ pi ops t,
          encode_all_operator_effects A_ pi ops t)
  end;

fun encode_problem_with_operator_interference_exclusion A_ pi t =
  And (encode_initial_state A_ pi,
        And (encode_operators A_ pi t,
              And (encode_all_frame_axioms A_ pi t,
                    And (encode_interfering_operator_exclusion A_ pi t,
                          encode_goal_state A_ pi t))));

fun variables_ofa
  (Sas_plus_problem_ext
    (variables_of, operators_of, initial_of, goal_of, range_of, more))
  = variables_of;

fun operators_ofa
  (Sas_plus_problem_ext
    (variables_of, operators_of, initial_of, goal_of, range_of, more))
  = operators_of;

fun initial_ofa
  (Sas_plus_problem_ext
    (variables_of, operators_of, initial_of, goal_of, range_of, more))
  = initial_of;

fun goal_ofa
  (Sas_plus_problem_ext
    (variables_of, operators_of, initial_of, goal_of, range_of, more))
  = goal_of;

fun range_of
  (Sas_plus_problem_ext
    (variables_of, operators_of, initial_of, goal_of, range_of, more))
  = range_of;

fun possible_assignments_for psi v =
  map (fn a => (v, a)) (the (range_of psi v));

fun state_to_strips_state A_ B_ psi s =
  let
    val defined = filter (fn v => not (is_none (s v))) (variables_ofa psi);
  in
    map_of (equal_prod A_ B_)
      (map (fn (v, a) => ((v, a), eq B_ (the (s v)) a))
        (maps (possible_assignments_for psi) defined))
  end;

fun precondition_ofa (Sas_plus_operator_ext (precondition_of, effect_of, more))
  = precondition_of;

fun effect_of (Sas_plus_operator_ext (precondition_of, effect_of, more)) =
  effect_of;

fun sasp_op_to_strips B_ psi opa =
  let
    val pre = precondition_ofa opa;
    val add = effect_of opa;
    val delete =
      maps (fn (v, a) =>
             map_filter
               (fn x => (if not (eq B_ a x) then SOME (v, x) else NONE))
               (the (range_of psi v)))
        (effect_of opa);
  in
    Strips_operator_ext (pre, add, delete, ())
  end;

fun sas_plus_problem_to_strips_problem A_ B_ psi =
  let
    val vs =
      maps (fn v => map (fn asa => asa) (possible_assignments_for psi v))
        (variables_ofa psi);
    val ops = map (sasp_op_to_strips B_ psi) (operators_ofa psi);
    val i = state_to_strips_state A_ B_ psi (initial_ofa psi);
    val g = state_to_strips_state A_ B_ psi (goal_ofa psi);
  in
    Strips_problem_ext (vs, ops, i, g, ())
  end;

fun abs_ast_variable_section problem =
  upt zero_nat (size_list (astDom problem));

fun abs_ast_operator x =
  (fn (_, (preconditions, (effects, _))) =>
    Sas_plus_operator_ext
      (preconditions, map (fn (_, a) => let
  val (v, aa) = a;
  val (_, ab) = aa;
in
  (v, ab)
end)
                        effects,
        ()))
    x;

fun abs_ast_operator_section problem = map abs_ast_operator (ast_delta problem);

fun abs_ast_initial_state problem =
  map_of equal_nat
    (zip (upt zero_nat (size_list (astI problem))) (astI problem));

fun abs_range_map problem =
  map_of equal_nat
    (zip (abs_ast_variable_section problem)
      (map ((fn vals => upt zero_nat (size_list vals)) o snd o snd)
        (astDom problem)));

fun abs_ast_goal problem = map_of equal_nat (astG problem);

fun abs_prob problem =
  Sas_plus_problem_ext
    (abs_ast_variable_section problem, abs_ast_operator_section problem,
      abs_ast_initial_state problem, abs_ast_goal problem,
      abs_range_map problem, ());

fun times_nat m n = Nat (IntInf.* (integer_of_nat m, integer_of_nat n));

fun var_to_dimacs h n_ops (State (t, k)) =
  plus_nat (plus_nat (plus_nat one_nat (times_nat n_ops h)) t) (times_nat k h)
  | var_to_dimacs h n_ops (Operator (t, k)) =
    plus_nat (plus_nat one_nat t) (times_nat k h);

val empty_sasp_action : ('a, 'b, unit) sas_plus_operator_ext =
  Sas_plus_operator_ext ([], [], ());

fun prob_with_noop pi =
  Sas_plus_problem_ext
    (variables_ofa pi, empty_sasp_action :: operators_ofa pi, initial_ofa pi,
      goal_ofa pi, range_of pi, ());

fun map_formula f (Atom x1) = Atom (f x1)
  | map_formula f Bot = Bot
  | map_formula f (Not x3) = Not (map_formula f x3)
  | map_formula f (And (x41, x42)) = And (map_formula f x41, map_formula f x42)
  | map_formula f (Or (x51, x52)) = Or (map_formula f x51, map_formula f x52)
  | map_formula f (Imp (x61, x62)) = Imp (map_formula f x61, map_formula f x62);

fun apsnd f (x, y) = (x, f y);

fun divmod_integer k l =
  (if ((k : IntInf.int) = (0 : IntInf.int))
    then ((0 : IntInf.int), (0 : IntInf.int))
    else (if IntInf.< ((0 : IntInf.int), l)
           then (if IntInf.< ((0 : IntInf.int), k)
                  then IntInf.divMod (IntInf.abs k, IntInf.abs l)
                  else let
                         val (r, s) =
                           IntInf.divMod (IntInf.abs k, IntInf.abs l);
                       in
                         (if ((s : IntInf.int) = (0 : IntInf.int))
                           then (IntInf.~ r, (0 : IntInf.int))
                           else (IntInf.- (IntInf.~ r, (1 : IntInf.int)),
                                  IntInf.- (l, s)))
                       end)
           else (if ((l : IntInf.int) = (0 : IntInf.int))
                  then ((0 : IntInf.int), k)
                  else apsnd IntInf.~
                         (if IntInf.< (k, (0 : IntInf.int))
                           then IntInf.divMod (IntInf.abs k, IntInf.abs l)
                           else let
                                  val (r, s) =
                                    IntInf.divMod (IntInf.abs k, IntInf.abs l);
                                in
                                  (if ((s : IntInf.int) = (0 : IntInf.int))
                                    then (IntInf.~ r, (0 : IntInf.int))
                                    else (IntInf.- (IntInf.~
              r, (1 : IntInf.int)),
   IntInf.- (IntInf.~ l, s)))
                                end))));

fun int_of_integer k =
  (if IntInf.< (k, (0 : IntInf.int))
    then uminus_int (int_of_integer (IntInf.~ k))
    else (if ((k : IntInf.int) = (0 : IntInf.int)) then Zero_int
           else let
                  val (l, j) = divmod_integer k (2 : IntInf.int);
                  val la = times_int (Pos (Bit0 One)) (int_of_integer l);
                in
                  (if ((j : IntInf.int) = (0 : IntInf.int)) then la
                    else plus_int la one_inta)
                end));

fun int_of_nat n = int_of_integer (integer_of_nat n);

fun disj_to_dimacs (Or (phi_1, phi_2)) =
  disj_to_dimacs phi_1 @ disj_to_dimacs phi_2
  | disj_to_dimacs Bot = []
  | disj_to_dimacs (Not Bot) = [uminus_int one_inta, one_inta]
  | disj_to_dimacs (Atom v) = [int_of_nat v]
  | disj_to_dimacs (Not (Atom v)) = [uminus_int (int_of_nat v)];

fun cnf_to_dimacs (And (phi_1, phi_2)) =
  cnf_to_dimacs phi_1 @ cnf_to_dimacs phi_2
  | cnf_to_dimacs (Atom v) = [disj_to_dimacs (Atom v)]
  | cnf_to_dimacs Bot = [disj_to_dimacs Bot]
  | cnf_to_dimacs (Not v) = [disj_to_dimacs (Not v)]
  | cnf_to_dimacs (Or (v, va)) = [disj_to_dimacs (Or (v, va))]
  | cnf_to_dimacs (Imp (v, va)) = [disj_to_dimacs (Imp (v, va))];

fun sASP_to_DIMACS h prob =
  cnf_to_dimacs
    (map_formula (var_to_dimacs (suc h) (suc (size_list (ast_delta prob))))
      (encode_problem_with_operator_interference_exclusion
        (equal_prod equal_nat equal_nat)
        (sas_plus_problem_to_strips_problem equal_nat equal_nat
          (prob_with_noop (abs_prob prob)))
        h));

fun sASP_to_DIMACSa h prob = sASP_to_DIMACS h (rem_implicit_pres_ops prob);

fun encode h prob =
  (if well_formed prob
    then (if list_all consistent_pres_op (ast_delta prob)
           then (if list_all is_standard_operator (ast_delta prob)
                  then Inl (sASP_to_DIMACSa h prob)
                  else Inr "Error: Conditional effects!")
           else Inr "Error: Preconditions inconsistent")
    else Inr "Error: Problem malformed!");

fun abs_int i = (if less_int i Zero_int then uminus_int i else i);

fun max_var xs =
  fold (fn x => fn y =>
         (if less_eq_int (abs_int y) (abs_int x) then abs_int x else y))
    xs Zero_int;

fun bit_cut_integer k =
  (if ((k : IntInf.int) = (0 : IntInf.int)) then ((0 : IntInf.int), false)
    else let
           val (r, s) =
             IntInf.divMod (IntInf.abs k, IntInf.abs (2 : IntInf.int));
         in
           ((if IntInf.< ((0 : IntInf.int), k) then r
              else IntInf.- (IntInf.~ r, s)),
             ((s : IntInf.int) = (1 : IntInf.int)))
         end);

fun char_of_integer k = let
                          val (q0, b0) = bit_cut_integer k;
                          val (q1, b1) = bit_cut_integer q0;
                          val (q2, b2) = bit_cut_integer q1;
                          val (q3, b3) = bit_cut_integer q2;
                          val (q4, b4) = bit_cut_integer q3;
                          val (q5, b5) = bit_cut_integer q4;
                          val (q6, b6) = bit_cut_integer q5;
                          val a = bit_cut_integer q6;
                          val (_, aa) = a;
                        in
                          Chara (b0, b1, b2, b3, b4, b5, b6, aa)
                        end;

fun explode s =
  map char_of_integer
    ((List.map (fn c => let val k = Char.ord c in if k < 128 then IntInf.fromInt k else raise Fail "Non-ASCII character in literal" end) 
       o String.explode)
      s);

fun nat_of_integer k = Nat (max ord_integer (0 : IntInf.int) k);

fun char_of_nat x = (char_of_integer o integer_of_nat) x;

fun nat_opt_of_integer i =
  (if IntInf.<= ((0 : IntInf.int), i) then SOME (nat_of_integer i) else NONE);

end; (*struct exported*)
