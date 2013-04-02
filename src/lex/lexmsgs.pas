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

unit lexmsgs;

interface

uses
  SysUtils;

var
  errors, warnings: integer;

(* - current error and warning count *)
procedure error(msg: string; pos: integer);
  (* - print current input line and error message (pos denotes position to
       mark in source file line) *)
procedure warning(msg: string; pos: integer);
(* - print warning message *)
procedure fatal(msg: string);
  (* - writes a fatal error message, erases Lex output file and terminates
       the program with errorlevel 1 *)

const

  (* sign-on and usage message: *)

  sign_on = 'Next Delphi Lex - Copyright (c) 2013 Roman Yankovsky'#13#10'Based on Delphi Lex - Copyright (c) 2003,2004 by Michiel Rook'#13#10'Based on Turbo Pascal Lex 4.1, Copyright (c) 1990-2000 Albert Graef';
  usage   = 'Usage: ndlex [options] lex-file[.l] [output-file[.pas]]';
  options = 'Options: -v verbose, -o optimize, -r readonly output';

  (* command line error messages: *)

  invalid_option  = 'invalid option ';
  illegal_no_args = 'illegal number of parameters';

  (* syntax errors: *)

  unmatched_lbrace = '101: unmatched %{';
  syntax_error     = '102: syntax error';
  unexpected_eof   = '103: unexpected end of file';

  (* semantic errors: *)

  symbol_already_defined = '201: symbol already defined';
  undefined_symbol = '202: undefined symbol';
  invalid_charnum  = '203: invalid character number';
  empty_grammar    = '204: empty grammar?';

  (* fatal errors: *)

  cannot_open_file = 'FATAL: cannot open file ';
  write_error      = 'FATAL: write error';
  mem_overflow     = 'FATAL: memory overflow';
  intset_overflow  = 'FATAL: integer set overflow';
  sym_table_overflow = 'FATAL: symbol table overflow';
  pos_table_overflow = 'FATAL: position table overflow';
  state_table_overflow = 'FATAL: state table overflow';
  trans_table_overflow = 'FATAL: transition table overflow';
  macro_stack_overflow = 'FATAL: macro stack overflow';

implementation

uses
  lexbase;

procedure position(var f: Text; lineNo: integer;
  line: string; pos: integer);
  (* writes a position mark of the form
     gfilename (lineno): line
                          ^
     on f with the caret ^ positioned at pos in line
     a subsequent write starts at the next line, indented with tab *)
var
  line1, line2: string;
begin
  (* this hack handles tab characters in line: *)
  line1 := IntToStr(lineNo) + ': ' + line;
  line2 := blankStr(IntToStr(lineNo) + ': ' + copy(line, 1, pos - 1));
  writeln(f, line1);
  writeln(f, line2, '^');
  Write(f, tab)
end(*position*);

procedure error(msg: string; pos: integer);
begin
  Inc(errors);
  writeln;
  position(output, lno, line, pos);
  writeln(msg);
  writeln(yylst);
  position(yylst, lno, line, pos);
  writeln(yylst, msg);
  if ioresult <> 0 then
  ;
end(*error*);

procedure warning(msg: string; pos: integer);
begin
  Inc(warnings);
  writeln;
  position(output, lno, line, pos);
  writeln(msg);
  writeln(yylst);
  position(yylst, lno, line, pos);
  writeln(yylst, msg);
  if ioresult <> 0 then
  ;
end(*warning*);

procedure fatal(msg: string);
begin
  writeln;
  writeln(msg);
  Close(yyin);
  Close(yyout);
  Close(yylst);
  erase(yyout);
  halt(1)
end(*fatal*);

begin
  errors   := 0;
  warnings := 0;
end(*LexMsgs*).
