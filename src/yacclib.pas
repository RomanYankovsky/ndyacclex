{
  Delphi Yacc & Lex
  Copyright (c) 2003,2004 by Michiel Rook
  Based on Turbo Pascal Lex and Yacc Version 4.1

  Copyright (c) 1990-92  Albert Graef <ag@muwiinfa.geschichte.uni-mainz.de>
  Copyright (C) 1996     Berend de Boer <berend@pobox.com>
  Copyright (c) 1998     Michael Van Canneyt <Michael.VanCanneyt@fys.kuleuven.ac.be>

  ## $Id: yacclib.pas 1697 2005-12-19 16:27:41Z druid $

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
unit yacclib;

interface

const
  yymaxdepth = 1024;
  (* default stack size of parser *)

type
  YYSType = integer;
  (* default value type, may be redefined in Yacc output file *)

  TCustomParser = class
  protected
    yychar: integer; (* current lookahead character *)
    yynerrs: integer;
    yyerrflag: integer;
    (* Flags used internally by the parser routine: *)
    yyflag: (yyfnone, yyfaccept, yyfabort, yyferror);
  public
    (* current number of syntax errors reported by the
      parser *)
    procedure yyerror(msg: string);
    (* error message printing routine used by the parser *)

    procedure yyclearin;
    (* delete the current lookahead token *)

    procedure yyaccept;
    (* trigger accept action of the parser; yyparse accepts returning 0, as if
      it reached end of input *)

    procedure yyabort;
    (* like yyaccept, but causes parser to return with value 1, as if an
      unrecoverable syntax error had been encountered *)

    procedure yyerrlab;
    (* causes error recovery to be started, as if a syntax error had been
      encountered *)

    procedure yyerrok;
    (* when in error mode, resets the parser to its normal mode of
      operation *)

    function parse() : integer; virtual; abstract;
  end;

implementation

procedure TCustomParser.yyerror(msg: string);
begin
  writeln(msg);
end (* yyerrmsg *);

procedure TCustomParser.yyclearin;
begin
  yychar := -1;
end (* yyclearin *);

procedure TCustomParser.yyaccept;
begin
  yyflag := yyfaccept;
end (* yyaccept *);

procedure TCustomParser.yyabort;
begin
  yyflag := yyfabort;
end (* yyabort *);

procedure TCustomParser.yyerrlab;
begin
  yyflag := yyferror;
end (* yyerrlab *);

procedure TCustomParser.yyerrok;
begin
  yyerrflag := 0;
end (* yyerrork *);

end (* YaccLib *)

  .
