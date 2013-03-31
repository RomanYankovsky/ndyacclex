{
  Delphi Yacc & Lex
  Copyright (c) 2003,2004 by Michiel Rook
  Based on Turbo Pascal Lex and Yacc Version 4.1

  Copyright (c) 1990-92  Albert Graef <ag@muwiinfa.geschichte.uni-mainz.de>
  Copyright (C) 1996     Berend de Boer <berend@pobox.com>
  Copyright (c) 1998     Michael Van Canneyt <Michael.VanCanneyt@fys.kuleuven.ac.be>
  
  ## $Id: yacclr0.pas 1325 2004-08-17 20:07:24Z druid $

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

unit yacclr0;

interface


procedure LR0Set;
  (* constructs the LR(0) state set, shift and goto transitions and
     corresponding kernel items *)

implementation

uses
  yaccbase,
  yacctabl;

(* This implementation is based on the algorithm given in Aho/Sethi/Ullman,
   1986, Section 4.7. *)

procedure get_syms(var item_set: ItemSet; var sym_set: IntSet);
(* get the symbols for which there are transitions in item_set *)
var
  i: integer;
begin
  with item_set do
  begin
    empty(sym_set);
    for i := 1 to n_items do
      with item[i], rule_table^[rule_no]^ do
        if pos_no <= rhs_len then
          include(sym_set, rhs_sym[pos_no]);
  end;
end(*get_syms*);

function make_state(var item_set: ItemSet; sym: integer): integer;
  (* construct a new state for the transitions in item_set on symbol sym;
     returns: the new state number *)
var
  i: integer;
begin
  with item_set do
  begin
    (* add the new state: *)
    new_state;
    for i := 1 to n_items do
      with item[i], rule_table^[rule_no]^ do
        if (pos_no <= rhs_len) and (rhs_sym[pos_no] = sym) then
          add_item(rule_no, pos_no + 1);
    Result := add_state;
  end;
end(*make_state*);

procedure add_next_links;
(* add links to successor items for kernel items in the active state *)
var
  k, i: integer;
begin
  with state_table^[act_state] do
    for k := trans_lo to trans_hi do
      with trans_table^[k] do
        for i := item_lo to item_hi do
          with item_table^[i], rule_table^[rule_no]^ do
            if (pos_no <= rhs_len) and (rhs_sym[pos_no] = sym) then
              Next := find_item(next_state, rule_no, pos_no + 1);
end(*add_next_links*);

procedure LR0Set;
var
  act_items: ItemSet;
  act_syms: IntSet;
  i: integer;
begin
  (* initialize state 0: *)
  new_state;
  add_item(1, 1);  (* augmented start production *)
  act_state := add_state;
  (* build the state table: *)
  repeat
    (* compute the closure of the current state: *)
    get_item_set(act_state, act_items);
    closure(act_items);
    (* sort items: *)
    sort_item_set(act_items);
    (* determine symbols used in shift and goto transitions: *)
    get_syms(act_items, act_syms);
    (* add transitions: *)
    start_trans;
    for i := 1 to size(act_syms) do
      if act_syms[i] = 0 then
        (* accept action *)
        add_trans(0, 0)
      else
        (* shift/goto action *)
        add_trans(act_syms[i], make_state(act_items, act_syms[i]));
    end_trans;
    (* add next links to kernel items: *)
    add_next_links;
    (* switch to next state: *)
    Inc(act_state);
  until act_state = n_states;
end(*LR0Set*);

end(*YaccLR0*).
