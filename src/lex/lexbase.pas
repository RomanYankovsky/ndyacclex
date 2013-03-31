{
  Delphi Yacc & Lex
  Copyright (c) 2003,2004 by Michiel Rook
  Based on Turbo Pascal Lex and Yacc Version 4.1

  Copyright (c) 1990-92  Albert Graef <ag@muwiinfa.geschichte.uni-mainz.de>
  Copyright (C) 1996     Berend de Boer <berend@pobox.com>
  Copyright (c) 1998     Michael Van Canneyt <Michael.VanCanneyt@fys.kuleuven.ac.be>
  
  ## $Id: lexbase.pas 1325 2004-08-17 20:07:24Z druid $

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}

unit lexbase;

interface


(* symbolic character constants: *)
const
  bs  = #8;             (* backspace character *)
  tab = #9;             (* tab character *)
  nl  = #10;            (* newline character *)
  cr  = #13;            (* carriage return *)
  ff  = #12;            (* form feed character *)

  max_elems = 100;  (* maximum size of integer sets *)

var
  (* Filenames: *)
  lfilename:   string;
  pasfilename: string;
  lstfilename: string;
  codfilename: string;
  codfilepath: string; { Under linux, binary and conf file 
                                                                                                                                                                        are not in the same path}
  (* Lex input, output, list and code template file: *)
  yyin, yylst, yyout, yycod: Text;

  (* the following values are initialized and updated by the parser: *)
  line: AnsiString;  (* current input line *)
  lno:  integer; (* current line number *)

type
  (* String and character class pointers: *)
  StrPtr    = PAnsiString;
  CClass    = set of char;
  CClassPtr = ^CClass;

  (* Sorted integer sets: *)
  IntSet    = array [0..max_elems] of integer;
  (* word 0 is size *)
  IntSetPtr = ^IntSet;

  (* Regular expressions: *)
  RegExpr = ^Node;

  NodeType = (mark_node,    (* marker node *)
    char_node,    (* character node *)
    str_node,     (* string node *)
    cclass_node,  (* character class node *)
    star_node,    (* star node *)
    plus_node,    (* plus node *)
    opt_node,     (* option node *)
    cat_node,     (* concatenation node *)
    alt_node);    (* alternatives node (|) *)

  Node = record
    case node_type: NodeType of
      mark_node: (rule, pos: integer);
      char_node: (c: AnsiChar);
      str_node: (str: StrPtr);
      cclass_node: (cc: CClassPtr);
      star_node, plus_node, opt_node: (r: RegExpr);
      cat_node, alt_node: (r1, r2: RegExpr);
  end;

const
  (* Some standard character classes: *)
  letters: CClass   = ['A'..'Z', 'a'..'z', '_'];
  digits: CClass    = ['0'..'9'];
  alphanums: CClass = ['A'..'Z', 'a'..'z', '_', '0'..'9'];

(* Operations: *)

(* Strings and character classes: *)

function newStr(str: AnsiString): StrPtr;
  (* creates a string pointer (only the space actually needed for the given
     string is allocated) *)
function newCClass(cc: CClass): CClassPtr;
(* creates a CClass pointer *)

(* Integer sets (set arguments are passed by reference even if they are not
   modified, for greater efficiency): *)

procedure empty(var M: IntSet);
(* initializes M as empty *)
procedure singleton(var M: IntSet; i: integer);
(* initializes M as a singleton set containing the element i *)
procedure include(var M: IntSet; i: integer);
(* include i in M *)
procedure exclude(var M: IntSet; i: integer);
(* exclude i from M *)
procedure setunion(var M, N: IntSet);
(* adds N to M *)
procedure setminus(var M, N: IntSet);
(* removes N from M *)
procedure intersect(var M, N: IntSet);
(* removes from M all elements NOT in N *)
function size(var M: IntSet): integer;
(* cardinality of set M *)
function member(i: integer; var M: IntSet): boolean;
(* tests for membership of i in M *)
function isempty(var M: IntSet): boolean;
(* checks whether M is an empty set *)
function equal(var M, N: IntSet): boolean;
(* checks whether M and N are equal *)
function subseteq(var M, N: IntSet): boolean;
(* checks whether M is a subset of N *)
function newIntSet: IntSetPtr;
(* creates a pointer to an empty integer set *)

(* Constructors for regular expressions: *)

const
  epsExpr: RegExpr = nil;

(* empty regular expression *)
function markExpr(rule, pos: integer): RegExpr;
  (* markers are used to denote endmarkers of rules, as well as other
     special positions in rules, e.g. the position of the lookahead
     operator; they are considered nullable; by convention, we use
     the following pos numbers:
     - 0: endmarker position
     - 1: lookahead operator position *)
function charExpr(c: AnsiChar): RegExpr;
(* character c *)
function strExpr(str: StrPtr): RegExpr;
(* "str" *)
function cclassExpr(cc: CClassPtr): RegExpr;
(* [str] where str are the literals in cc *)
function starExpr(r: RegExpr): RegExpr;
(* r* *)
function plusExpr(r: RegExpr): RegExpr;
(* r+ *)
function optExpr(r: RegExpr): RegExpr;
(* r? *)
function mnExpr(r: RegExpr; m, n: integer): RegExpr;
  (* constructor expanding expression r{m,n} to the corresponding
     alt expression r^m|...|r^n *)
function catExpr(r1, r2: RegExpr): RegExpr;
(* r1r2 *)
function altExpr(r1, r2: RegExpr): RegExpr;
(* r1|r2 *)

(* Unifiers for regular expressions:
   The following predicates check whether the specified regular
   expression r is of the denoted type; if the predicate succeeds,
   the other arguments of the predicate are instantiated to the
   corresponding values. *)

function is_epsExpr(r: RegExpr): boolean;
(* empty regular expression *)
function is_markExpr(r: RegExpr; var rule, pos: integer): boolean;
(* marker expression *)
function is_charExpr(r: RegExpr; var c: AnsiChar): boolean;
(* character c *)
function is_strExpr(r: RegExpr; var str: StrPtr): boolean;
(* "str" *)
function is_cclassExpr(r: RegExpr; var cc: CClassPtr): boolean;
(* [str] where str are the literals in cc *)
function is_starExpr(r: RegExpr; var r1: RegExpr): boolean;
(* r1* *)
function is_plusExpr(r: RegExpr; var r1: RegExpr): boolean;
(* r1+ *)
function is_optExpr(r: RegExpr; var r1: RegExpr): boolean;
(* r1? *)
function is_catExpr(r: RegExpr; var r1, r2: RegExpr): boolean;
(* r1r2 *)
function is_altExpr(r: RegExpr; var r1, r2: RegExpr): boolean;
(* r1|r2 *)

(* Quicksort: *)

type

  OrderPredicate = function(i, j: integer): boolean;
  SwapProc = procedure(i, j: integer);

procedure quicksort(lo, hi: integer; less: OrderPredicate;
  swap: SwapProc);
  (* General inplace sorting procedure based on the quicksort algorithm.
     This procedure can be applied to any sequential data structure;
     only the corresponding routines less which compares, and swap which
     swaps two elements i,j of the target data structure, must be
     supplied as appropriate for the target data structure.
     - lo, hi: the lower and higher indices, indicating the elements to
       be sorted
     - less(i, j): should return true if element no. i `is less than'
       element no. j, and false otherwise; any total quasi-ordering may
       be supplied here (if neither less(i, j) nor less(j, i) then elements
       i and j are assumed to be `equal').
     - swap(i, j): should swap the elements with index i and j *)

(* Generic hash table routines (based on quadratic rehashing; hence the
   table size must be a prime number): *)

type

  TableLookupProc = function(k: integer): AnsiString;
  TableEntryProc  = procedure(k: integer; symbol: AnsiString);

function key(symbol: AnsiString; table_size: integer;
  lookup: TableLookupProc; entry: TableEntryProc): integer;
  (* returns a hash table key for symbol; inserts the symbol into the
     table if necessary
     - table_size is the symbol table size and must be a fixed prime number
     - lookup is the table lookup procedure which should return the string
       at key k in the table ('' if entry is empty)
     - entry is the table entry procedure which is assumed to store the
       given symbol at the given location *)

function definedKey(symbol: AnsiString; table_size: integer;
  lookup: TableLookupProc): boolean;
(* checks the table to see if symbol is in the table *)

(* Utility routines: *)

function min(i, j: integer): integer;
function max(i, j: integer): integer;
(* minimum and maximum of two integers *)
function nchars(cc: CClass): integer;
(* returns the cardinality (number of characters) of a character class *)
function strip(str: AnsiString): AnsiString;
(* returns str with leading and trailing blanks stripped off *)
function blankStr(str: AnsiString): AnsiString;
  (* returns string of same length as str, with all non-whitespace characters
     replaced by blanks *)
function isInt(str: AnsiString; var i: integer): boolean;
  (* checks whether str represents an integer; if so, returns the
     value of it in i *)
function path(filename: string): string;
(* returns the path in filename *)
function root(filename: string): string;
  (* returns root (i.e. extension stripped from filename) of
     filename *)
function addExt(filename, ext: string): string;
  (* if filename has no extension and last filename character is not '.',
     add extension ext to filename *)
function file_size(filename: string): longint;
(* determines file size in bytes *)

(* Utility functions for list generating routines: *)

function charStr(c: AnsiChar; reserved: CClass): AnsiString;
  (* returns a print name for character c, using the standard escape
     conventions; reserved is the class of `reserved' special characters
     which should be quoted with \ (\ itself is always quoted) *)
function singleQuoteStr(str: AnsiString): AnsiString;
  (* returns print name of str enclosed in single quotes, using the
     standard escape conventions *)
function doubleQuoteStr(str: AnsiString): AnsiString;
  (* returns print name of str enclosed in double quotes, using the
     standard escape conventions *)
function cclassStr(cc: CClass): AnsiString;
  (* returns print name of character class cc, using the standard escape
     conventions; if cc contains more than 128 elements, the complement
     notation (^) is used; if cc is the class of all (non-null) characters
     except newline, the period notation is used *)
function cclassOrCharStr(cc: CClass): AnsiString;
  (* returns a print name for character class cc (either cclassStr, or,
     if cc contains only one element, character in single quotes) *)
function regExprStr(r: RegExpr): AnsiString;
(* unparses a regular expression *)

implementation

uses
  lexmsgs, SysUtils;

(* String and character class pointers: *)

function newStr(str: AnsiString): StrPtr;
begin
  Result := SysUtils.NewStr(str);
end(*newStr*);

function newCClass(cc: CClass): CClassPtr;
var
  ccp: CClassPtr;
begin
  new(ccp);
  ccp^      := cc;
  Result := ccp;
end(*newCClass*);

(* Integer sets: *)

procedure empty(var M: IntSet);
begin
  M[0] := 0;
end(*empty*);

procedure singleton(var M: IntSet; i: integer);
begin
  M[0] := 1;
  M[1] := i;
end(*singleton*);

procedure include(var M: IntSet; i: integer);
var
  l, r, k: integer;
begin
  (* binary search: *)
  l := 1;
  r := M[0];
  k := l + (r - l) div 2;
  while (l < r) and (M[k] <> i) do
  begin
    if M[k] < i then
      l := succ(k)
    else
      r := pred(k);
    k := l + (r - l) div 2;
  end;
  if (k > M[0]) or (M[k] <> i) then
  begin
    if M[0] >= max_elems then
      fatal(intset_overflow);
    if (k <= M[0]) and (M[k] < i) then
    begin
      move(M[k + 1], M[k + 2], (M[0] - k) * sizeOf(integer));
      M[k + 1] := i;
    end
    else  begin
      move(M[k], M[k + 1], (M[0] - k + 1) * sizeOf(integer));
      M[k] := i;
    end;
    Inc(M[0]);
  end;
end(*include*);

procedure exclude(var M: IntSet; i: integer);
var
  l, r, k: integer;
begin
  (* binary search: *)
  l := 1;
  r := M[0];
  k := l + (r - l) div 2;
  while (l < r) and (M[k] <> i) do
  begin
    if M[k] < i then
      l := succ(k)
    else
      r := pred(k);
    k := l + (r - l) div 2;
  end;
  if (k <= M[0]) and (M[k] = i) then
  begin
    move(M[k + 1], M[k], (M[0] - k) * sizeOf(integer));
    Dec(M[0]);
  end;
end(*exclude*);

procedure setunion(var M, N: IntSet);
var
  K: IntSet;
  i, j, i_M, i_N: integer;
begin
  (* merge sort: *)
  i   := 0;
  i_M := 1;
  i_N := 1;
  while (i_M <= M[0]) and (i_N <= N[0]) do
  begin
    Inc(i);
    if i > max_elems then
      fatal(intset_overflow);
    if M[i_M] < N[i_N] then
    begin
      K[i] := M[i_M];
      Inc(i_M);
    end
    else if N[i_N] < M[i_M] then
    begin
      K[i] := N[i_N];
      Inc(i_N);
    end
    else  begin
      K[i] := M[i_M];
      Inc(i_M);
      Inc(i_N);
    end
  end;
  for j := i_M to M[0] do
  begin
    Inc(i);
    if i > max_elems then
      fatal(intset_overflow);
    K[i] := M[j];
  end;
  for j := i_N to N[0] do
  begin
    Inc(i);
    if i > max_elems then
      fatal(intset_overflow);
    K[i] := N[j];
  end;
  K[0] := i;
  move(K, M, succ(i) * sizeOf(integer));
end(*setunion*);

procedure setminus(var M, N: IntSet);
var
  K: IntSet;
  i, i_M, i_N: integer;
begin
  i   := 0;
  i_N := 1;
  for i_M := 1 to M[0] do
  begin
    while (i_N <= N[0]) and (N[i_N] < M[i_M]) do
      Inc(i_N);
    if (i_N > N[0]) or (N[i_N] > M[i_M]) then
    begin
      Inc(i);
      K[i] := M[i_M];
    end
    else
      Inc(i_N);
  end;
  K[0] := i;
  move(K, M, succ(i) * sizeOf(integer));
end(*setminus*);

procedure intersect(var M, N: IntSet);
var
  K: IntSet;
  i, i_M, i_N: integer;
begin
  i   := 0;
  i_N := 1;
  for i_M := 1 to M[0] do
  begin
    while (i_N <= N[0]) and (N[i_N] < M[i_M]) do
      Inc(i_N);
    if (i_N <= N[0]) and (N[i_N] = M[i_M]) then
    begin
      Inc(i);
      K[i] := M[i_M];
      Inc(i_N);
    end
  end;
  K[0] := i;
  move(K, M, succ(i) * sizeOf(integer));
end(*intersect*);

function size(var M: IntSet): integer;
begin
  Result := M[0]
end(*size*);

function member(i: integer; var M: IntSet): boolean;
var
  l, r, k: integer;
begin
  (* binary search: *)
  l := 1;
  r := M[0];
  k := l + (r - l) div 2;
  while (l < r) and (M[k] <> i) do
  begin
    if M[k] < i then
      l := succ(k)
    else
      r := pred(k);
    k := l + (r - l) div 2;
  end;
  Result := (k <= M[0]) and (M[k] = i);
end(*member*);

function isempty(var M: IntSet): boolean;
begin
  Result := M[0] = 0
end(*isempty*);

function equal(var M, N: IntSet): boolean;
var
  i: integer;
begin
  if M[0] <> N[0] then
    Result := False
  else  begin
    for i := 1 to M[0] do
      if M[i] <> N[i] then
      begin
        Result := False;
        exit;
      end;
    Result := True
  end
end(*equal*);

function subseteq(var M, N: IntSet): boolean;
var
  i_M, i_N: integer;
begin
  if M[0] > N[0] then
    Result := False
  else  begin
    i_N := 1;
    for i_M := 1 to M[0] do
    begin
      while (i_N <= N[0]) and (N[i_N] < M[i_M]) do
        Inc(i_N);
      if (i_N > N[0]) or (N[i_N] > M[i_M]) then
      begin
        Result := False;
        exit
      end
      else
        Inc(i_N);
    end;
    Result := True
  end;
end(*subseteq*);

function newIntSet: IntSetPtr;
var
  MP: IntSetPtr;
begin
  getmem(MP, (max_elems + 1) * sizeOf(integer));
  MP^[0]    := 0;
  Result := MP
end(*newIntSet*);

(* Constructors for regular expressions: *)

function newExpr(node_type: NodeType; n: integer): RegExpr;
  (* returns new RegExpr node (n: number of bytes to allocate) *)
var
  x: RegExpr;
begin
  getmem(x, sizeOf(NodeType) + n);
  x^.node_type := node_type;
  Result      := x
end(*newExpr*);

function markExpr(rule, pos: integer): RegExpr;
var
  x: RegExpr;
begin
  x      := newExpr(mark_node, 2 * sizeOf(integer));
  x^.rule := rule;
  x^.pos := pos;
  Result := x
end(*markExpr*);

function charExpr(c: AnsiChar): RegExpr;
var
  x: RegExpr;
begin
  x    := newExpr(char_node, sizeOf(AnsiChar));
  x^.c := c;
  Result := x
end(*charExpr*);

function strExpr(str: StrPtr): RegExpr;
var
  x: RegExpr;
begin
  x      := newExpr(str_node, sizeOf(StrPtr));
  x^.str := str;
  Result := x
end(*strExpr*);

function cclassExpr(cc: CClassPtr): RegExpr;
var
  x: RegExpr;
begin
  x     := newExpr(cclass_node, sizeOf(CClassPtr));
  x^.cc := cc;
  Result := x
end(*cclassExpr*);

function starExpr(r: RegExpr): RegExpr;
var
  x: RegExpr;
begin
  x    := newExpr(star_node, sizeOf(RegExpr));
  x^.r := r;
  Result := x
end(*starExpr*);

function plusExpr(r: RegExpr): RegExpr;
var
  x: RegExpr;
begin
  x    := newExpr(plus_node, sizeOf(RegExpr));
  x^.r := r;
  Result := x
end(*plusExpr*);

function optExpr(r: RegExpr): RegExpr;
var
  x: RegExpr;
begin
  x    := newExpr(opt_node, sizeOf(RegExpr));
  x^.r := r;
  Result := x
end(*optExpr*);

function mnExpr(r: RegExpr; m, n: integer): RegExpr;
var
  ri, rmn: RegExpr;
  i: integer;
begin
  if (m > n) or (n = 0) then
    Result := epsExpr
  else  begin
    (* construct r^m: *)
    if m = 0 then
      ri := epsExpr
    else  begin
      ri := r;
      for i := 2 to m do
        ri := catExpr(ri, r);
    end;
    (* construct r{m,n}: *)
    rmn := ri;                  (* r{m,n} := r^m *)
    for i := m + 1 to n do
    begin
      if is_epsExpr(ri) then
        ri := r
      else
        ri := catExpr(ri, r);
      rmn := altExpr(rmn, ri)  (* r{m,n} := r{m,n} | r^i,
                                        i=m+1,...,n *)
    end;
    Result := rmn
  end
end(*mnExpr*);

function catExpr(r1, r2: RegExpr): RegExpr;
var
  x: RegExpr;
begin
  x     := newExpr(cat_node, 2 * sizeOf(RegExpr));
  x^.r1 := r1;
  x^.r2 := r2;
  Result := x
end(*catExpr*);

function altExpr(r1, r2: RegExpr): RegExpr;
var
  x: RegExpr;
begin
  x     := newExpr(alt_node, 2 * sizeOf(RegExpr));
  x^.r1 := r1;
  x^.r2 := r2;
  Result := x
end(*altExpr*);

(* Unifiers for regular expressions: *)

function is_epsExpr(r: RegExpr): boolean;
begin
  Result := r = epsExpr
end(*is_epsExpr*);

function is_markExpr(r: RegExpr; var rule, pos: integer): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = mark_node then
  begin
    Result := True;
    rule := r^.rule;
    pos  := r^.pos;
  end
  else
    Result := False
end(*is_markExpr*);

function is_charExpr(r: RegExpr; var c: AnsiChar): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = char_node then
  begin
    Result := True;
    c := r^.c
  end
  else
    Result := False
end(*is_charExpr*);

function is_strExpr(r: RegExpr; var str: StrPtr): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = str_node then
  begin
    Result := True;
    str := r^.str;
  end
  else
    Result := False
end(*is_strExpr*);

function is_cclassExpr(r: RegExpr; var cc: CClassPtr): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = cclass_node then
  begin
    Result := True;
    cc := r^.cc
  end
  else
    Result := False
end(*is_cclassExpr*);

function is_starExpr(r: RegExpr; var r1: RegExpr): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = star_node then
  begin
    Result := True;
    r1 := r^.r
  end
  else
    Result := False
end(*is_starExpr*);

function is_plusExpr(r: RegExpr; var r1: RegExpr): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = plus_node then
  begin
    Result := True;
    r1 := r^.r
  end
  else
    Result := False
end(*is_plusExpr*);

function is_optExpr(r: RegExpr; var r1: RegExpr): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = opt_node then
  begin
    Result := True;
    r1 := r^.r
  end
  else
    Result := False
end(*is_optExpr*);

function is_catExpr(r: RegExpr; var r1, r2: RegExpr): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = cat_node then
  begin
    Result := True;
    r1 := r^.r1;
    r2 := r^.r2
  end
  else
    Result := False
end(*is_catExpr*);

function is_altExpr(r: RegExpr; var r1, r2: RegExpr): boolean;
begin
  if r = epsExpr then
    Result := False
  else if r^.node_type = alt_node then
  begin
    Result := True;
    r1 := r^.r1;
    r2 := r^.r2
  end
  else
    Result := False
end(*is_altExpr*);

(* Quicksort: *)

procedure quicksort(lo, hi: integer; less: OrderPredicate;
  swap: SwapProc);
  (* derived from the quicksort routine in QSORT.PAS in the Turbo Pascal
     distribution *)
  procedure sort(l, r: integer);
  var
    i, j, k: integer;
  begin
    i := l;
    j := r;
    k := (l + r) div 2;
    repeat
      while less(i, k) do
        Inc(i);
      while less(k, j) do
        Dec(j);
      if i <= j then
      begin
        swap(i, j);
        if k = i then
          k := j (* pivot element swapped! *)
        else if k = j then
          k := i;
        Inc(i);
        Dec(j);
      end;
    until i > j;
    if l < j then
      sort(l, j);
    if i < r then
      sort(i, r);
  end(*sort*);
begin
  if lo < hi then
    sort(lo, hi);
end(*quicksort*);

(* Generic hash table routines: *)

function hash(str: AnsiString; table_size: integer): integer;
  (* computes a hash key for str *)
var
  i, key: integer;
begin
  key := 0;
  for i := 1 to length(str) do
    Inc(key, Ord(str[i]));
  Result := key mod table_size + 1;
end(*hash*);

procedure newPos(var pos, incr, Count: integer; table_size: integer);
  (* computes a new position in the table (quadratic collision strategy)
     - pos: current position (+inc)
     - incr: current increment (+2)
     - count: current number of collisions (+1)
     quadratic collision formula for position of str after n collisions:
       pos(str, n) = (hash(str)+n^2) mod table_size +1
     note that n^2-(n-1)^2 = 2n-1 <=> n^2 = (n-1)^2 + (2n-1) for n>0,
     i.e. the increment inc=2n-1 increments by two in each collision *)
begin
  Inc(Count);
  Inc(pos, incr);
  if pos > table_size then
    pos := pos mod table_size + 1;
  Inc(incr, 2)
end(*newPos*);

function key(symbol: AnsiString; table_size: integer;
  lookup: TableLookupProc; entry: TableEntryProc): integer;
var
  pos, incr, Count: integer;
begin
  pos   := hash(symbol, table_size);
  incr  := 1;
  Count := 0;
  while Count <= table_size do
    if lookup(pos) = '' then
    begin
      entry(pos, symbol);
      Result := pos;
      exit;
    end
    else if lookup(pos) = symbol then
    begin
      Result := pos;
      exit;
    end
    else
      newPos(pos, incr, Count, table_size);
  fatal(sym_table_overflow)
end(*key*);

function definedKey(symbol: AnsiString; table_size: integer;
  lookup: TableLookupProc): boolean;
var
  pos, incr, Count: integer;
begin
  pos   := hash(symbol, table_size);
  incr  := 1;
  Count := 0;
  while Count <= table_size do
    if lookup(pos) = '' then
    begin
      Result := False;
      exit;
    end
    else if lookup(pos) = symbol then
    begin
      Result := True;
      exit;
    end
    else
      newPos(pos, incr, Count, table_size);
  Result := False
end(*definedKey*);

(* Utility routines: *)

function min(i, j: integer): integer;
begin
  if i < j then
    Result := i
  else
    Result := j
end(*min*);

function max(i, j: integer): integer;
begin
  if i > j then
    Result := i
  else
    Result := j
end(*max*);

function nchars(cc: CClass): integer;
var
  c:     AnsiChar;
  Count: integer;
begin
  Count := 0;
  for c := #0 to #255 do
    if c in cc then
      Inc(Count);
  Result := Count;
end(*nchars*);

function strip(str: AnsiString): AnsiString;
begin
  while (length(str) > 0) and ((str[1] = ' ') or (str[1] = tab)) do
    Delete(str, 1, 1);
  while (length(str) > 0) and
    ((str[length(str)] = ' ') or
      (str[length(str)] = tab)) do
    Delete(str, length(str), 1);
  Result := str;
end(*strip*);

function blankStr(str: AnsiString): AnsiString;
var
  i: integer;
begin
  for i := 1 to length(str) do
    if str[i] <> tab then
      str[i] := ' ';
  Result := str;
end(*blankStr*);

function isInt(str: AnsiString; var i: integer): boolean;
var
  res: integer;
begin
  val(str, i, res);
  Result := res = 0;
end(*isInt*);

function path(filename: string): string;
var
  i: integer;
begin
  i := length(filename);
  while (i > 0) and (filename[i] <> '\') and (filename[i] <> ':') do
    Dec(i);
  Result := copy(filename, 1, i);
end(*path*);

function root(filename: string): string;
var
  i: integer;
begin
  root := filename;
  for i := length(filename) downto 1 do
    case filename[i] of
      '.':
      begin
        Result := copy(filename, 1, i - 1);
        exit
      end;
      '\': exit;
      else
    end;
end(*addExt*);

function addExt(filename, ext: string): string;
  (* implemented with goto for maximum efficiency *)
label
  x;
var
  i: integer;
begin
  Result := filename;
  for i := length(filename) downto 1 do
    case filename[i] of
      '.': exit;
      '\': goto x;
      else
    end;
  x:
    Result := filename + '.' + ext
end(*addExt*);

function file_size(filename: string): longint;
var
  f: file;
begin
  Assign(f, filename);
  reset(f, 1);
  if ioresult = 0 then
    Result := fileSize(f)
  else
    Result := 0;
  Close(f);
end(*file_size*);

(* Utility functions for list generating routines: *)

function charStr(c: AnsiChar; reserved: CClass): AnsiString;

  function octStr(c: AnsiChar): AnsiString;
    (* return octal string representation of character c *)
  begin
    Result := IntToStr(Ord(c) div 64) + IntToStr((Ord(c) mod 64) div 8) +
      IntToStr(Ord(c) mod 8);
  end(*octStr*);
begin
  case c of
    #0..#7,      (* nonprintable characters *)
    #11, #14..#31,
    #127..#255: Result := '\' + octStr(c);
    bs: Result  := '\b';
    tab: Result := '\t';
    nl: Result  := '\n';
    cr: Result  := '\c';
    ff: Result  := '\f';
    '\': Result := '\\';
    else if c in reserved then
        Result := '\' + c
      else
        Result := c
  end
end(*charStr*);

function singleQuoteStr(str: AnsiString): AnsiString;
var
  i:    integer;
  str1: AnsiString;
begin
  str1 := '';
  for i := 1 to length(str) do
    str1 := str1 + charStr(str[i], ['''']);
  Result := '''' + str1 + ''''
end(*singleQuoteStr*);

function doubleQuoteStr(str: AnsiString): AnsiString;
var
  i:    integer;
  str1: AnsiString;
begin
  str1 := '';
  for i := 1 to length(str) do
    str1 := str1 + charStr(str[i], ['"']);
  Result := '"' + str1 + '"'
end(*doubleQuoteStr*);

function cclassStr(cc: CClass): AnsiString;
const
  reserved: CClass = ['^', '-', ']'];
  MaxChar = #255;
var
  c1, c2: AnsiChar;
  str:    AnsiString;
  Quit:   boolean;
begin
  if cc = [#1..#255] - [nl] then
    Result := '.'
  else  begin
    str := '';
    if nchars(cc) > 128 then
    begin
      str := '^';
      cc  := [#0..#255] - cc;
    end;
    c1   := chr(0);
    Quit := False;
    while not Quit do
    begin
      if c1 in cc then
      begin
        c2 := c1;
        while (c2 < MaxChar) and (succ(c2) in cc) do
          c2 := succ(c2);
        if c1 = c2 then
          str := str + charStr(c1, reserved)
        else if c2 = succ(c1) then
          str := str + charStr(c1, reserved) + charStr(c2, reserved)
        else
          str := str + charStr(c1, reserved) + '-' + charStr(c2, reserved);
        c1 := c2;
      end;
      Quit := c1 = MaxChar;
      if not Quit then
        c1 := Succ(c1);
    end; { of while }
    Result := '[' + str + ']'
  end
end(*cclassStr*);

function cclassOrCharStr(cc: CClass): AnsiString;
var
  Count: integer;
  c, c1: AnsiChar;
begin
  Count := 0;
  for c := #0 to #255 do
    if c in cc then
    begin
      c1 := c;
      Inc(Count);
      if Count > 1 then
      begin
        Result := cclassStr(cc);
        exit;
      end;
    end;
  if Count = 1 then
    Result := singleQuoteStr(c1)
  else
    Result := '[]';
end(*cclassOrCharStr*);

function regExprStr(r: RegExpr): AnsiString;

  function unparseExpr(r: RegExpr): AnsiString;
  var
    rule_no, pos: integer;
    c:      AnsiChar;
    str:    StrPtr;
    cc:     CClassPtr;
    r1, r2: RegExpr;
  begin
    if is_epsExpr(r) then
      Result := ''
    else if is_markExpr(r, rule_no, pos) then
      Result := '#(' + IntToStr(rule_no) + ',' + IntToStr(pos) + ')'
    else if is_charExpr(r, c) then
      Result := charStr(c, ['"', '.', '^', '$', '[', ']', '*', '+', '?',
        '{', '}', '|', '(', ')', '/', '<', '>'])
    else if is_strExpr(r, str) then
      Result := doubleQuoteStr(str^)
    else if is_cclassExpr(r, cc) then
      Result := cclassStr(cc^)
    else if is_starExpr(r, r1) then
      Result := unparseExpr(r1) + '*'
    else if is_plusExpr(r, r1) then
      Result := unparseExpr(r1) + '+'
    else if is_optExpr(r, r1) then
      Result := unparseExpr(r1) + '?'
    else if is_catExpr(r, r1, r2) then
      Result := '(' + unparseExpr(r1) + unparseExpr(r2) + ')'
    else if is_altExpr(r, r1, r2) then
      Result := '(' + unparseExpr(r1) + '|' + unparseExpr(r2) + ')'
    else
      fatal('invalid expression');
  end(*unparseExpr*);
begin
  Result := unparseExpr(r);
end(*regExprStr*);

end(*LexBase*).
