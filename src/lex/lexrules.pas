{
  Delphi Yacc & Lex
  Copyright (c) 2003,2004 by Michiel Rook
  Based on Turbo Pascal Lex and Yacc Version 4.1

  Copyright (c) 1990-92  Albert Graef <ag@muwiinfa.geschichte.uni-mainz.de>
  Copyright (C) 1996     Berend de Boer <berend@pobox.com>
  Copyright (c) 1998     Michael Van Canneyt <Michael.VanCanneyt@fys.kuleuven.ac.be>
  
  ## $Id: lexrules.pas 1325 2004-08-17 20:07:24Z druid $

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

unit lexrules;

interface

uses
  lexbase,
  lextable;

procedure parse_rule(rule_no: integer);
(* rule parser (rule_no=number of parsed rule) *)

(* Return values of rule parser: *)

var

  expr, stmt: AnsiString;
  (* expression and statement part of rule *)
  cf:   boolean;
  (* caret flag *)
  n_st: integer;
  (* number of start states in prefix *)
  st:   array [1..max_states] of integer;
  (* start states *)
  r:    RegExpr;
(* parsed expression *)

implementation

uses
  lexmsgs;

(* Scanner routines:

   The following routines provide access to the source line and handle
   macro substitutions. To perform macro substitution, an input buffer
   is maintained which contains the rest of the line to be parsed, plus
   any pending macro substitutions. The input buffer is organized as
   a stack onto which null-terminated replacement strings are pushed
   as macro substitutions are processed (the terminating null-character
   is used as an endmarker for macros, in order to keep track of the
   number of pending macro substitutions); characters are popped from the
   stack via calls to the get_char routine.

   In order to perform macro substitution, the scanner also has to
   maintain some state information to be able to determine when it
   is scanning quoted characters, strings or character classes (s.t.
   no macro substitution is performed in such cases).

   The scanner also keeps track of the current source line position in
   variable act_pos; if there are any macro substitutions on the stack,
   act_pos will point to the position of the original macro call in the
   source line. This is needed to give proper error diagnostics. *)

const
  max_chars = 2048;

var

  act_pos, bufptr: integer;
  (* current position in source line and input stack pointer *)
  buf:      array [1..max_chars] of AnsiChar;
  (* input buffer *)
  str_state, cclass_state, quote_state: boolean;
  (* state information *)
  n_macros: integer;

(* number of macros currently on stack *)

procedure mark_error(msg: string; offset: integer);
  (* mark error position (offset=offset of error position (to the left of
     act_pos) *)
begin
  if n_macros = 0 then
    error(msg, act_pos - offset)
  else
    error(msg + ' in regular definition', act_pos)
end(*mark_error*);

procedure put_str(str: AnsiString);
(* push str onto input stack *)
var
  i: integer;
begin
  Inc(bufptr, length(str));
  if bufptr > max_chars then
    fatal(macro_stack_overflow);
  for i := 1 to length(str) do
    buf[bufptr - i + 1] := str[i];
end(*put_str*);

procedure init_scanner;
(* initialize the scanner *)
begin
  act_pos     := 1;
  bufptr      := 0;
  str_state   := False;
  cclass_state := False;
  quote_state := False;
  n_macros    := 0;
  put_str(line);
end(*init_scanner*);

function act_char: AnsiChar;
  (* current character (#0 if none) *)
  function push_macro: boolean;
    (* check for macro call at current position in input buffer *)
    function scan_macro(var Name: AnsiString): boolean;
    var
      i: integer;
    begin
      if (bufptr > 1) and
        (buf[bufptr] = '{') and (buf[bufptr - 1] in letters) then
      begin
        Name := '{';
        i    := bufptr - 1;
        while (i > 0) and (buf[i] in alphanums) do
        begin
          Name := Name + buf[i];
          Dec(i);
        end;
        if (i > 0) and (buf[i] = '}') then
        begin
          Result := True;
          Name   := Name + '}';
          bufptr := i - 1;
        end
        else  begin
          Result := False;
          mark_error(syntax_error, -length(Name));
          bufptr := i;
        end
      end
      else
        Result := False
    end(*scan_macro*);
  var
    Name: AnsiString;
  begin
    if scan_macro(Name) then
    begin
      Result := True;
{$ifdef fpc}
          with sym_table^[key(name, max_keys, @lookup, @entry)] do
{$else}
      with sym_table^[key(Name, max_keys, lookup, entry)] do
{$endif}
        if sym_type = macro_sym then
        begin
          put_str(subst^ + #0);
          Inc(n_macros);
        end
        else
          mark_error(undefined_symbol, -1)
    end
    else
      Result := False
  end(*push_macro*);

  function pop_macro: boolean;
    (* check for macro endmarker *)
  begin
    if (bufptr > 0) and (buf[bufptr] = #0) then
    begin
      Dec(bufptr);
      Dec(n_macros);
      if n_macros = 0 then
        act_pos := length(line) - bufptr + 1;
      Result := True;
    end
    else
      Result := False
  end(*pop_macro*);
begin
  if not (str_state or cclass_state or quote_state) then
    while push_macro do
      while pop_macro do ;
  if bufptr = 0 then
    Result := #0
  else  begin
    while pop_macro do ;
    if bufptr > 0 then
      Result := buf[bufptr]
    else
      Result := #0;
  end
end(*act_char*);

procedure get_char;
(* get next character *)
begin
  if bufptr > 0 then
  begin
    case buf[bufptr] of
      '\': quote_state := not quote_state;
      '"': if quote_state then
          quote_state := False
        else if not cclass_state then
          str_state := not str_state;
      '[': if quote_state then
          quote_state := False
        else if not str_state then
          cclass_state := True;
      ']': if quote_state then
          quote_state := False
        else if not str_state then
          cclass_state := False;
      else  quote_state := False;
    end;
    Dec(bufptr);
    if n_macros = 0 then
      act_pos := length(line) - bufptr + 1;
  end
end(*get_char*);

(* Semantic routines: *)

procedure add_start_state(symbol: AnsiString);
(* add start state to st array *)
begin
{$ifdef fpc}
    with sym_table^[key(symbol, max_keys, @lookup, @entry)] do
{$else}
  with sym_table^[key(symbol, max_keys, lookup, entry)] do
{$endif}
    if sym_type = start_state_sym then
    begin
      if n_st >= max_start_states then
        exit; { this shouldn't happen }
      Inc(n_st);
      st[n_st] := start_state;
    end
    else
      mark_error(undefined_symbol, length(symbol))
end(*add_start_state*);

(* Parser: *)

procedure parse_rule(rule_no: integer);

  procedure rule(var done: boolean);

    (* parse rule according to syntax:

       rule                                    : start_state_prefix caret
                                                  expr [ '$' | '/' expr ]
                                                ;

       start_state_prefix            : /* empty */
                                                | '<' start_state_list '>'
                                                ;

       start_state_list         : ident { ',' ident }
                                ;

       caret                                    : /* empty */
                                                | '^'
                                                ;

       expr                                    : term { '|' term }
                                                ;

       term                                    : factor { factor }
                                                ;

       factor                                    : char
                                                | string
                                                | cclass
                                                | '.'
                                                | '(' expr ')'
                                                | factor '*'
                                                | factor '+'
                                                | factor '?'
                                                | factor '{' num [ ',' num ] '}'
                                                ;
    *)

    procedure start_state_prefix(var done: boolean);

      procedure start_state_list(var done: boolean);

        procedure ident(var done: boolean);
        var
          idstr: AnsiString;
        begin(*ident*)
          done := act_char in letters;
          if not done then
            exit;
          idstr := act_char;
          get_char;
          while act_char in alphanums do
          begin
            idstr := idstr + act_char;
            get_char;
          end;
          add_start_state(idstr);
        end(*ident*);
      begin(*start_state_list*)
        ident(done);
        if not done then
          exit;
        while act_char = ',' do
        begin
          get_char;
          ident(done);
          if not done then
            exit;
        end;
      end(*start_state_list*);
    begin(*start_state_prefix*)
      n_st := 0;
      if act_char = '<' then
      begin
        get_char;
        start_state_list(done);
        if not done then
          exit;
        if act_char = '>' then
        begin
          done := True;
          get_char;
        end
        else
          done := False
      end
      else
        done := True
    end(*start_state_prefix*);

    procedure caret(var done: boolean);
    begin(*caret*)
      done := True;
      cf   := act_char = '^';
      if act_char = '^' then
        get_char;
    end(*caret*);

    procedure scan_char(var done: boolean; var c: AnsiChar);
    var
      oct_val: byte;
      Count:   integer;
    begin
      done := True;
      if act_char = '\' then
      begin
        get_char;
        case act_char of
          #0: done := False;
          'n':
          begin
            c := nl;
            get_char
          end;
          'r':
          begin
            c := cr;
            get_char
          end;
          't':
          begin
            c := tab;
            get_char
          end;
          'b':
          begin
            c := bs;
            get_char
          end;
          'f':
          begin
            c := ff;
            get_char
          end;
          '0'..'7':
          begin
            oct_val := Ord(act_char) - Ord('0');
            get_char;
            Count := 1;
            while ('0' <= act_char) and
              (act_char <= '7') and
              (Count < 3) do
            begin
              Inc(Count);
              oct_val := oct_val * 8 + Ord(act_char) - Ord('0');
              get_char
            end;
            c := AnsiChar(chr(oct_val));
          end
          else
          begin
            c := act_char;
            get_char
          end
        end
      end
      else  begin
        c := act_char;
        get_char
      end
    end(*scan_char*);

    procedure scan_str(var done: boolean; var str: AnsiString);
    var
      c: AnsiChar;
    begin
      str := '';
      get_char;
      while (act_char <> #0) and (act_char <> '"') do
      begin
        scan_char(done, c);
        if not done then
          exit;
        str := str + c;
      end;
      if act_char = #0 then
        done := False
      else  begin
        get_char;
        done := True;
      end
    end(*scan_str*);

    procedure scan_cclass(var done: boolean; var cc: CClass);
    (* scan a character class *)
    var
      caret:     boolean;
      c, c1, cl: AnsiChar;
    begin
      cc := [];
      get_char;
      if act_char = '^' then
      begin
        caret := True;
        get_char;
      end
      else
        caret := False;
      while (act_char <> #0) and (act_char <> ']') do
      begin
        scan_char(done, c);
        if not done then
          exit;
        if act_char = '-' then
        begin
          get_char;
          if (act_char <> #0) and (act_char <> ']') then
          begin
            scan_char(done, c1);
            if not done then
              exit;
            for cl := c to c1 do
              cc := cc + [cl];
            {cc := cc+[c..c1];}
          end
          else
            cc := cc + [c, '-'];
        end
        else
          cc := cc + [c];
      end;
      if act_char = #0 then
        done := False
      else  begin
        get_char;
        done := True;
      end;
      if caret then
        cc := [#1..#255] - cc;
    end(*scan_cclass*);

    procedure scan_num(var done: boolean; var n: integer);
    var
      str: AnsiString;
    begin
      if act_char in digits then
      begin
        str := act_char;
        get_char;
        while act_char in digits do
        begin
          str := str + act_char;
          get_char;
        end;
        done := isInt(str, n);
      end
      else
        done := False
    end(*scan_num*);

    procedure DoExpr(var done: boolean; var r: RegExpr);

      procedure term(var done: boolean; var r: RegExpr);

        procedure factor(var done: boolean; var r: RegExpr);
        var
          str:  AnsiString;
          cc:   CClass;
          c:    AnsiChar;
          n, m: integer;
        begin(*factor*)
          case act_char of
            '"':
            begin
              scan_str(done, str);
              if not done then
                exit;
              r := strExpr(newStr(str));
            end;
            '[':
            begin
              scan_cclass(done, cc);
              if not done then
                exit;
              r := cclassExpr(newCClass(cc));
            end;
            '.':
            begin
              get_char;
              r    := cclassExpr(newCClass([#1..#255] - [nl]));
              done := True;
            end;
            '(':
            begin
              get_char;
              DoExpr(done, r);
              if not done then
                exit;
              if act_char = ')' then
              begin
                get_char;
                done := True;
              end
              else
                done := False
            end;
            else
            begin
              scan_char(done, c);
              if not done then
                exit;
              r := charExpr(c);
            end;
          end;
          while done and (act_char in ['*', '+', '?', '{']) do
            case act_char of
              '*':
              begin
                get_char;
                r := starExpr(r);
              end;
              '+':
              begin
                get_char;
                r := plusExpr(r);
              end;
              '?':
              begin
                get_char;
                r := optExpr(r);
              end;
              '{':
              begin
                get_char;
                scan_num(done, m);
                if not done then
                  exit;
                if act_char = ',' then
                begin
                  get_char;
                  scan_num(done, n);
                  if not done then
                    exit;
                  r := mnExpr(r, m, n);
                end
                else
                  r := mnExpr(r, m, m);
                if act_char = '}' then
                begin
                  get_char;
                  done := True;
                end
                else
                  done := False
              end;
            end
        end(*factor*);
      const
        term_delim: CClass = [#0, ' ', tab, '$', '|', ')', '/'];
      var
        r1: RegExpr;
      begin(*term*)
        if not (act_char in term_delim) then
        begin
          factor(done, r);
          if not done then
            exit;
          while not (act_char in term_delim) do
          begin
            factor(done, r1);
            if not done then
              exit;
            r := catExpr(r, r1);
          end
        end
        else  begin
          r    := epsExpr;
          done := True;
        end
      end(*term*);
    var
      r1: RegExpr;
    begin(*expr*)
      term(done, r);
      if not done then
        exit;
      while act_char = '|' do
      begin
        get_char;
        term(done, r1);
        if not done then
          exit;
        r := altExpr(r, r1);
      end
    end(*expr*);

  var
    r1, r2: RegExpr;

  begin(*rule*)
    start_state_prefix(done);
    if not done then
      exit;
    caret(done);
    if not done then
      exit;
    DoExpr(done, r1);
    if not done then
      exit;
    if act_char = '$' then
    begin
      r := catExpr(catExpr(r1,
        markExpr(rule_no, 1)),
        cclassExpr(newCClass([nl])));
      get_char;
    end
    else if act_char = '/' then
    begin
      get_char;
      DoExpr(done, r2);
      if not done then
        exit;
      r := catExpr(catExpr(r1,
        markExpr(rule_no, 1)), r2);
    end
    else
      r := catExpr(r1, markExpr(rule_no, 1));
    r := catExpr(r, markExpr(rule_no, 0));
    done := (act_char = #0) or (act_char = ' ') or (act_char = tab);
  end(*rule*);

var
  done: boolean;

begin(*parse_rule*)
  init_scanner;
  rule(done);
  if done then
  begin
    expr := copy(line, 1, act_pos - 1);
    stmt := copy(line, act_pos, length(line));
  end
  else
    mark_error(syntax_error, 0)
end(*parse_rule*);

end(*LexRules*).
