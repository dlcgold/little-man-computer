/* stato random */
state(Acc, Pc, Mem, In, Out, Flag) :-
    numlist(0, 999, L),
    member(Acc, L),
    member(Pc, L),
    randseq(99, 999, Mem),
    numlist(0, 999, In),
    numlist(0, 999, Out),
    member(Flag,  [flag, noflag]).

/* capisco numero istruzione */
istruzione(Pc, Mem , I) :- randseq(99, 999, Mem),
                           numlist(0, 999, L),
                           member(Pc, L),
                           nth0(Pc, Mem, I, _).

/* istruzione nxx tengo xx */
cellarisultato(I, X) :- number_chars(I, L),
                        nth0(0, L, _, L2),
                        number_chars(X, L2).

/* istruzioni */
addizione(Acc, Istr, X) :- Istr > 99, Istr < 200,
                           cellarisultato(Istr, Istrv),
                           X is ((Acc+Istrv) mod 1000).

sottrazione(Acc, Istr, X) :- Istr > 199, Istr < 300,
                             cellarisultato(Istr, Istrv),
                             X is ((Acc-Istrv) mod 1000).

store(Acc, Istr, Mem) :- Istr > 299, Istr < 400,
                         cellarisultato(Istr, Istrv),
                         randseq(99, 999, Mem),
                         nth0(Istrv, Mem, Acc, _).

load(Acc, Istr, Mem) :- Istr > 499, Istr < 600,
                        cellarisultato(Istr, Istrv),
                        randseq(99, 999, Mem),
                        nth0(Istrv, Mem, X, _),
                        Acc is X.

branch(Pc, Istr) :- Istr > 599, Istr < 700,
                    cellarisultato(Istr, Istrv),
                    Pc is Istrv.

branchifzero(Pc, Acc, Istr) :- Istr > 699, Istr < 800,
                               cellarisultato(Istr, Istrv),
                               Acc is 0,
                               Pc is Istrv.

branchifpositive(Pc, Istr, Flag) :- Istr > 799, Istr< 900,
                                    cellarisultato(Istr, Istrv),
                                    member(Flag, [noflag]),
                                    Pc is Istrv.

input(Acc, In, Istr, NewIn) :- Istr is 901,
                               nth0(0, In, Elem, NewIn),
                               Acc is Elem.

output(Acc, Out, Istr, NewOut) :- Istr is 902,
                                  append(Out, [Acc], NewOut).

term :- halt.
