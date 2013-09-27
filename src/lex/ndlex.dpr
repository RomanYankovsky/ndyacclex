{
  Next Delphi Yacc & Lex
  Copyright (c) 2013 by Roman Yankovsky <roman@yankovsky.me>
  Based on Delphi Yacc & Lex Version 1.4
  Based on Turbo Pascal Lex and Yacc Version 4.1

  Copyright (c) 1990-92   Albert Graef <ag@muwiinfa.geschichte.uni-mainz.de>
  Copyright (C) 1996      Berend de Boer <berend@pobox.com>
  Copyright (c) 1998      Michael Van Canneyt <Michael.VanCanneyt@fys.kuleuven.ac.be>
  Copyright (c) 2003-2004 Michiel Rook

  ## $Id: lexlib.pas 1697 2005-12-19 16:27:41Z druid $

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}

{$I-}
program ndlex;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$APPTYPE CONSOLE}

uses
  SysUtils,
  lexbase,
  lextable,
  lexpos,
  lexdfa,
  lexopt,
  lexlist,
  lexrules,
  lexmsgs;
  
  
procedure get_line;
(* obtain line from source file *)
begin
  readln(yyin, line);
  Inc(lno);
end(*get_line*);

procedure next_section;
(* find next section mark (%%) in code template *)
var
  line: string;
begin
  while not EOF(yycod) do
  begin
    readln(yycod, line);
    if line = '%%' then
      exit;
    writeln(yyout, line);
  end;
end(*next_section*);

(* Semantic routines: *)

var
  n_rules: integer; (* current number of rules *)

procedure define_start_state(symbol: AnsiString; pos: integer);
(* process start state definition *)
begin
{$ifdef fpc}
    with sym_table^[key(symbol, max_keys, @lookup, @entry)] do
{$else}
  with sym_table^[key(symbol, max_keys, lookup, entry)] do
{$endif}
    if sym_type = none then
    begin
      Inc(n_start_states);
      if n_start_states > max_start_states then
        fatal(state_table_overflow);
      sym_type    := start_state_sym;
      start_state := n_start_states;
      writeln(yyout, 'const ', symbol, ' = ', 2 * start_state, ';');
      first_pos_table^[2 * start_state]     := newIntSet;
      first_pos_table^[2 * start_state + 1] := newIntSet;
    end
    else
      error(symbol_already_defined, pos)
end(*define_start_state*);

procedure define_macro(symbol, replacement: AnsiString);
(* process macro definition *)
begin
{$ifdef fpc}
    with sym_table^[key('{'+symbol+'}', max_keys, @lookup, @entry)] do
{$else}
  with sym_table^[key('{' + symbol + '}', max_keys, lookup, entry)] do
{$endif}
    if sym_type = none then
    begin
      sym_type := macro_sym;
      subst    := newStr(strip(replacement));
    end
    else
      error(symbol_already_defined, 1)
end(*define_macro*);

procedure add_rule;
(* process rule *)
var
  i:     integer;
  First: IntSet;
begin
  addExpr(r, First);
  if n_st = 0 then
    if cf then
      setunion(first_pos_table^[1]^, First)
    else begin
      setunion(first_pos_table^[0]^, First);
      setunion(first_pos_table^[1]^, First);
    end
  else if cf then
    for i := 1 to n_st do
      setunion(first_pos_table^[2 * st[i] + 1]^, First)
  else
    for i := 1 to n_st do
    begin
      setunion(first_pos_table^[2 * st[i]]^, First);
      setunion(first_pos_table^[2 * st[i] + 1]^, First);
    end
end(*add_rule*);

procedure generate_table;

  (* write the DFA table to the output file

     Tables are represented as a collection of typed array constants:

     type YYTRec = record
                     cc : set of Char; { characters }
                     s  : Integer;     { next state }
                   end;

     const

     { table sizes: }

     yynmarks   = ...;
     yynmatches = ...;
     yyntrans   = ...;
     yynstates  = ...;

     { rules of mark positions for each state: }

     yyk : array [1..yynmarks] of Integer = ...;

     { rules of matches for each state: }

     yym : array [1..yynmatches] of Integer = ...;

     { transition table: }

     yyt : array [1..yyntrans] of YYTRec = ...;

     { offsets into the marks, matches and transition tables: }

     yykl, yykh,
     yyml, yymh,
     yytl, yyth : array [0..yynstates-1] of Integer = ...;

  *)

var
  yynmarks, yynmatches, yyntrans, yynstates: integer;
  yykl, yykh, yyml, yymh, yytl, yyth: array [0..max_states - 1] of integer;

  procedure counters;
  (* compute counters and offsets *)
  var
    s, i: integer;
  begin
    yynstates  := n_states;
    yyntrans   := n_trans;
    yynmarks   := 0;
    yynmatches := 0;
    for s := 0 to n_states - 1 do
      with state_table^[s] do
      begin
        yytl[s] := trans_lo;
        yyth[s] := trans_hi;
        yykl[s] := yynmarks + 1;
        yyml[s] := yynmatches + 1;
        for i := 1 to size(state_pos^) do
          with pos_table^[state_pos^[i]] do
            if pos_type = mark_pos then
              if pos = 0 then
                Inc(yynmatches)
              else if pos = 1 then
                Inc(yynmarks);
        yykh[s] := yynmarks;
        yymh[s] := yynmatches;
      end;
  end(*counters*);

  procedure writecc(var f: Text; cc: CClass);
  (* print the given character class *)
    function charStr(c: AnsiChar): AnsiString;
    begin
      case c of
        #0..#31,     (* nonprintable characters *)
        #127..#255: Result := '#' + IntToStr(Ord(c));
        '''': Result := '''''''''';
        else  Result := '''' + c + '''';
      end;
    end(*charStr*);
  const
    MaxChar = #255;
  var
    c1, c2: AnsiChar;
    col:    integer;
    tag:    AnsiString;
    Quit:   boolean;
  begin
    Write(f, '[ ');
    col  := 0;
    c1   := chr(0);
    Quit := False;
    while not Quit do
    begin
      if c1 in cc then
      begin
        if col > 0 then
        begin
          Write(f, ',');
          Inc(col);
        end;
        if col > 40 then
          { insert line break }
        begin
          writeln(f);
          Write(f, ' ': 12);
          col := 0;
        end;
        c2 := c1;
        while (c2 < MaxChar) and (succ(c2) in cc) do
          c2 := succ(c2);
        if c1 = c2 then
          tag := charStr(c1)
        else if c2 = succ(c1) then
          tag := charStr(c1) + ',' + charStr(c2)
        else
          tag := charStr(c1) + '..' + charStr(c2);
        Write(f, tag);
        col := col + length(tag);
        c1  := c2;
      end;
      Quit := c1 = MaxChar;
      if not Quit then
        c1 := Succ(c1);
    end; { of while }
    Write(f, ' ]');
  end(*writecc*);

  procedure tables;
  (* print tables *)
  var
    s, i, Count: integer;
  begin
    writeln(yyout);
    writeln(yyout, 'type YYTRec = record');
    writeln(yyout, '                cc : set of Char;');
    writeln(yyout, '                s  : Integer;');
    writeln(yyout, '              end;');
    writeln(yyout);
    writeln(yyout, 'const');
    (* table sizes: *)
    writeln(yyout);
    writeln(yyout, 'yynmarks   = ', yynmarks, ';');
    writeln(yyout, 'yynmatches = ', yynmatches, ';');
    writeln(yyout, 'yyntrans   = ', yyntrans, ';');
    writeln(yyout, 'yynstates  = ', yynstates, ';');
    (* mark table: *)
    writeln(yyout);
    writeln(yyout, 'yyk : array [1..yynmarks] of Integer = (');
    Count := 0;
    for s := 0 to n_states - 1 do
      with state_table^[s] do
      begin
        writeln(yyout, '  { ', s, ': }');
        for i := 1 to size(state_pos^) do
          with pos_table^[state_pos^[i]] do
            if (pos_type = mark_pos) and (pos = 1) then
            begin
              Write(yyout, '  ', rule);
              Inc(Count);
              if Count < yynmarks then
                Write(yyout, ',');
              writeln(yyout);
            end;
      end;
    writeln(yyout, ');');
    (* match table: *)
    writeln(yyout);
    writeln(yyout, 'yym : array [1..yynmatches] of Integer = (');
    Count := 0;
    for s := 0 to n_states - 1 do
      with state_table^[s] do
      begin
        writeln(yyout, '{ ', s, ': }');
        for i := 1 to size(state_pos^) do
          with pos_table^[state_pos^[i]] do
            if (pos_type = mark_pos) and (pos = 0) then
            begin
              Write(yyout, '  ', rule);
              Inc(Count);
              if Count < yynmatches then
                Write(yyout, ',');
              writeln(yyout);
            end;
      end;
    writeln(yyout, ');');
    (* transition table: *)
    writeln(yyout);
    writeln(yyout, 'yyt : array [1..yyntrans] of YYTrec = (');
    Count := 0;
    for s := 0 to n_states - 1 do
      with state_table^[s] do
      begin
        writeln(yyout, '{ ', s, ': }');
        for i := trans_lo to trans_hi do
          with trans_table^[i] do
          begin
            Write(yyout, '  ( cc: ');
            writecc(yyout, cc^);
            Write(yyout, '; s: ');
            Write(yyout, next_state, ')');
            Inc(Count);
            if Count < yyntrans then
              Write(yyout, ',');
            writeln(yyout);
          end;
      end;
    writeln(yyout, ');');
    (* offset tables: *)
    writeln(yyout);
    writeln(yyout, 'yykl : array [0..yynstates-1] of Integer = (');
    for s := 0 to n_states - 1 do
    begin
      Write(yyout, '{ ', s, ': } ', yykl[s]);
      if s < n_states - 1 then
        Write(yyout, ',');
      writeln(yyout);
    end;
    writeln(yyout, ');');
    writeln(yyout);
    writeln(yyout, 'yykh : array [0..yynstates-1] of Integer = (');
    for s := 0 to n_states - 1 do
    begin
      Write(yyout, '{ ', s, ': } ', yykh[s]);
      if s < n_states - 1 then
        Write(yyout, ',');
      writeln(yyout);
    end;
    writeln(yyout, ');');
    writeln(yyout);
    writeln(yyout, 'yyml : array [0..yynstates-1] of Integer = (');
    for s := 0 to n_states - 1 do
    begin
      Write(yyout, '{ ', s, ': } ', yyml[s]);
      if s < n_states - 1 then
        Write(yyout, ',');
      writeln(yyout);
    end;
    writeln(yyout, ');');
    writeln(yyout);
    writeln(yyout, 'yymh : array [0..yynstates-1] of Integer = (');
    for s := 0 to n_states - 1 do
    begin
      Write(yyout, '{ ', s, ': } ', yymh[s]);
      if s < n_states - 1 then
        Write(yyout, ',');
      writeln(yyout);
    end;
    writeln(yyout, ');');
    writeln(yyout);
    writeln(yyout, 'yytl : array [0..yynstates-1] of Integer = (');
    for s := 0 to n_states - 1 do
    begin
      Write(yyout, '{ ', s, ': } ', yytl[s]);
      if s < n_states - 1 then
        Write(yyout, ',');
      writeln(yyout);
    end;
    writeln(yyout, ');');
    writeln(yyout);
    writeln(yyout, 'yyth : array [0..yynstates-1] of Integer = (');
    for s := 0 to n_states - 1 do
    begin
      Write(yyout, '{ ', s, ': } ', yyth[s]);
      if s < n_states - 1 then
        Write(yyout, ',');
      writeln(yyout);
    end;
    writeln(yyout, ');');
    writeln(yyout);
  end(*tables*);

begin
  counters;
  tables;
end(*generate_table*);

(* Parser: *)

const

  max_items = 255;

var

  itemstr: AnsiString;
  itemc:   integer;
  itempos, itemlen: array [1..max_items] of integer;

procedure split(str: AnsiString; Count: integer);
  (* split str into at most count whitespace-delimited items
     (result in itemstr, itemc, itempos, itemlen) *)
  procedure scan(var act_pos: integer);
  (* scan one item *)
  var
    l: integer;
  begin
    while (act_pos <= length(itemstr)) and
      ((itemstr[act_pos] = ' ') or (itemstr[act_pos] = tab)) do
      Inc(act_pos);
    l := 0;
    while (act_pos + l <= length(itemstr)) and
      (itemstr[act_pos + l] <> ' ') and (itemstr[act_pos + l] <> tab) do
      Inc(l);
    Inc(itemc);
    itempos[itemc] := act_pos;
    itemlen[itemc] := l;
    Inc(act_pos, l + 1);
    while (act_pos <= length(itemstr)) and
      ((itemstr[act_pos] = ' ') or (itemstr[act_pos] = tab)) do
      Inc(act_pos);
  end(*scan*);
var
  act_pos: integer;
begin
  itemstr := str;
  act_pos := 1;
  itemc   := 0;
  while (itemc < Count - 1) and (act_pos <= length(itemstr)) do
    scan(act_pos);
  if act_pos <= length(itemstr) then
  begin
    Inc(itemc);
    itempos[itemc] := act_pos;
    itemlen[itemc] := length(itemstr) - act_pos + 1;
  end;
end(*split*);

function itemv(i: integer): AnsiString;
  (* return ith item in splitted string (whole string for i=0) *)
begin
  if i = 0 then
    Result := itemstr
  else if (i < 0) or (i > itemc) then
    Result := ''
  else
    Result := copy(itemstr, itempos[i], itemlen[i])
end(*itemv*);

procedure code;
begin
  while not EOF(yyin) do
  begin
    get_line;
    if line = '%}' then
      exit
    else
      writeln(yyout, line);
  end;
  error(unmatched_lbrace, length(line) + 1);
end(*code*);

procedure definitions;

  procedure definition;

    function check_id(symbol: AnsiString): boolean;
    var
      i: integer;
    begin
      if (symbol = '') or not (symbol[1] in letters) then
        Result := False
      else begin
        for i := 2 to length(symbol) do
          if not (symbol[i] in alphanums) then
          begin
            Result := False;
            exit;
          end;
        Result := True
      end
    end(*check_id*);
  var
    i:   integer;
    com: AnsiString;
  begin
    split(line, 2);
    com := UpperCase(itemv(1));
    if (com = '%S') or (com = '%START') then
    begin
      split(line, max_items);
      for i := 2 to itemc do
        if check_id(itemv(i)) then
          define_start_state(itemv(i), itempos[i])
        else
          error(syntax_error, itempos[i]);
    end
    else if check_id(itemv(1)) then
      define_macro(itemv(1), itemv(2))
    else
      error(syntax_error, 1);
  end(*definition*);
begin
  while not EOF(yyin) do
  begin
    get_line;
    if line = '' then
      writeln(yyout)
    else if line = '%%' then
      exit
    else if line = '%{' then
      code
    else if (line[1] = '%') or (line[1] in letters) then
      definition
    else
      writeln(yyout, line)
  end;
end(*definitions*);

procedure rules;
begin
  next_section;
  if line = '%%' then
    while not EOF(yyin) do
    begin
      get_line;
      if line = '' then
        writeln(yyout)
      else if line = '%%' then
      begin
        next_section;
        exit;
      end
      else if line = '%{' then
        code
      else if (line[1] <> ' ') and (line[1] <> tab) then
      begin
        if n_rules = 0 then
          next_section;
        Inc(n_rules);
        parse_rule(n_rules);
        if errors = 0 then
        begin
          add_rule;
          Write(yyout, '  ', n_rules);
          if strip(stmt) = '|' then
            writeln(yyout, ',')
          else begin
            writeln(yyout, ':');
            writeln(yyout, blankStr(expr), stmt);
          end;
        end
      end
      else
        writeln(yyout, line)
    end
  else
    error(unexpected_eof, length(line) + 1);
  next_section;
end(*rules*);

procedure auxiliary_procs;
begin
  if line = '%%' then
  begin
    writeln(yyout);
    while not EOF(yyin) do
    begin
      get_line;
      writeln(yyout, line);
    end;
  end;
end(*auxiliary_procs*);

(* Main program: *)

var
  i:     integer;
  Attrs: integer;

procedure openCodFile();
begin
  (* search code template in /usr/share/dyacclex/ (on linux),
     then current directory, then on path where Lex
     was executed from: *)

  codfilepath := ExtractFilePath(ParamStr(0));

  {$IFDEF LINUX}
  codfilename := '/usr/share/dyacclex/yylex.cod';
  Assign(yycod, codfilename);
  reset(yycod);

  if (IOResult = 0) then
    exit;
  {$ENDIF}

  codfilename := 'yylex.cod';
  Assign(yycod, codfilename);
  reset(yycod);

  if (IOResult = 0) then
    exit;

  codfilename := codfilepath + 'yylex.cod';
  Assign(yycod, codfilename);
  reset(yycod);
      
  if (IOResult = 0) then
    exit;
    
  fatal(cannot_open_file + 'yylex.cod');
end;

begin
  (* sign-on: *)

  writeln(sign_on);

  (* parse command line: *)

  if paramCount = 0 then
  begin
    writeln;
    writeln(usage);
    writeln(options);
    halt(0);
  end;

  lfilename   := '';
  pasfilename := '';

  for i := 1 to paramCount do
    if copy(ParamStr(i), 1, 1) = '-' then
      if UpperCase(ParamStr(i)) = '-V' then
        verbose := True
      else if UpperCase(ParamStr(i)) = '-R' then
        readonlyflag := True
      else if UpperCase(ParamStr(i)) = '-O' then
        optimize := True
      else begin
        writeln(invalid_option, ParamStr(i));
        halt(1);
      end
    else if lfilename = '' then
      lfilename := addExt(ParamStr(i), 'l')
    else if pasfilename = '' then
      pasfilename := addExt(ParamStr(i), 'pas')
    else begin
      writeln(illegal_no_args);
      halt(1);
    end;

  if lfilename = '' then
  begin
    writeln(illegal_no_args);
    halt(1);
  end;

  if pasfilename = '' then
    pasfilename := root(lfilename) + '.pas';
  lstfilename := root(lfilename) + '.lst';

  (* open files: *)

{$WARN SYMBOL_PLATFORM OFF}
{$IFDEF MSWINDOWS}
  if readonlyflag then
  begin
    if FileExists(pasfilename) then
    begin
      Attrs := FileGetAttr(pasfilename);
      FileSetAttr(pasfilename, Attrs and not faReadOnly);
    end;
  end;
{$WARN SYMBOL_PLATFORM ON}
{$ENDIF}

  Assign(yyin, lfilename);
  Assign(yyout, pasfilename);
  Assign(yylst, lstfilename);

  reset(yyin);
  if ioresult <> 0 then
    fatal(cannot_open_file + lfilename);
  rewrite(yyout);
  if ioresult <> 0 then
    fatal(cannot_open_file + pasfilename);
  rewrite(yylst);
  if ioresult <> 0 then
    fatal(cannot_open_file + lstfilename);
    
  openCodFile();

  (* parse source grammar: *)

  Write('parse ... ');
  lno     := 0;
  n_rules := 0;
  next_section;
  first_pos_table^[0] := newIntSet;
  first_pos_table^[1] := newIntSet;
  definitions;
  rules;
  if n_rules = 0 then
    error(empty_grammar, length(line) + 1);
  if errors = 0 then
  begin
    (* generate DFA table and listings and write output code: *)
    Write('DFA construction ... ');
    makeDFATable;
    if optimize then
    begin
      Write('DFA optimization ... ');
      optimizeDFATable;
    end;
    Write('code generation ... ');
    if verbose then
      listDFATable;
    generate_table;
    next_section;
  end;
  auxiliary_procs;
  if errors = 0 then
    writeln('DONE');

  (* close files: *)

  Close(yyin);
  Close(yyout);
  Close(yylst);
  Close(yycod);

{$WARN SYMBOL_PLATFORM OFF}
{$IFDEF MSWINDOWS}
  if readonlyflag then
  begin
    Attrs := FileGetAttr(pasfilename);
    FileSetAttr(pasfilename, Attrs or faReadOnly);
  end;
{$ENDIF}
{$WARN SYMBOL_PLATFORM ON}

  (* print statistics: *)

  if errors > 0 then
    writeln(lno, ' lines, ',
      errors, ' errors found.')
  else
    writeln(lno, ' lines, ',
      n_rules, ' rules, ',
      n_pos, '/', max_pos, ' p, ',
      n_states, '/', max_states, ' s, ',
      n_trans, '/', max_trans, ' t.');

  if warnings > 0 then
    writeln(warnings, ' warnings.');

  (* terminate: *)

  if errors > 0 then
    erase(yyout);
  if file_size(lstfilename) = 0 then
    erase(yylst)
  else
    writeln('(see ', lstfilename, ' for more information)');

  halt(errors);

end(*Lex*).
