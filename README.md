# TimesTable.jl

Generates a set of randomised times-table (and addition!) questions of given factors (f), but
stochastically includes the commutative pair (i.e. c × f = f × c) and the inverse operation
'division fact' (c × f = a, then ask a ÷ f) in the next few questions.

Currently copied + pasted into a Google Docs, for practice questions for my kids.

(12 questions on an A4 sheet on Google Docs, Roboto 34, 1.5 line spacing)

Example output:
```quote
Generating 24 × questions; factors 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, range 1:12. Inverse operations: true.

___ ÷ 10 = 3
___ × 10 = 30
3 × ___ = 3
5 × ___ = 40
3 ___ 3 = 1
___ × 10 = 20
1 × 3 = ___
8 ___ 5 = 40
10 × ___ = 30
72 ÷ ___ = 9
10 ___ 2 = 20
9 × ___ = 72
7 ___ 2 = 14
8 × ___ = 72
___ ÷ 5 = 12
20 ÷ 10 = ___
___ × 7 = 14
___ × 2 = 6
___ × 9 = 36
36 ___ 4 = 9
9 ___ 4 = 36
___ × 3 = 6
5 ___ 12 = 60
33 ___ 3 = 11
```
