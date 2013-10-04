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

program ndyacc;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$APPTYPE CONSOLE}
{$X+}
{$I-}
{$H-}
{$R+}
{$Q+}

{%File 'ndyacc.y'}

uses
  SysUtils,
  lexlib,
  yacclib,
  yaccbase,
  yaccmsgs,
  yaccsem,
  yacctabl,
  yaccpars;

const ID = 257;
const C_ID = 258;
const LITERAL = 259;
const LITID = 260;
const NUMBER = 261;
const PTOKEN = 262;
const PLEFT = 263;
const PRIGHT = 264;
const PNONASSOC = 265;
const PTYPE = 266;
const PSTART = 267;
const PPREC = 268;
const PUNION = 269;
const PP = 270;
const LCURL = 271;
const RCURL = 272;
const ILLEGAL = 273;
type YYSType = Integer(*YYSType*);
// source: yyparse.cod line# 2

var yylval : YYSType;

type
  TLexer = class(TCustomLexer)
  private
    bufptr: integer;
    buf: array [1 .. max_chars] of AnsiChar;

    yyinput, yyoutput: Text; // input and output file
  protected
    function get_char: AnsiChar; override;
    procedure unget_char(c: AnsiChar); override;
    procedure put_char(c: AnsiChar); override;
    procedure yyclear; override;
    function yywrap: boolean; override;
  public
    constructor Create;

    function parse() : integer; override;
  end;

  TParser = class(TCustomParser)
  public
    lexer : TLexer;

    function parse() : integer; override;
  end;


constructor TLexer.Create;
begin
  inherited Create;
  Assign(yyinput, '');
  Assign(yyoutput, '');
  reset(yyinput);
  rewrite(yyoutput);
end;

function TLexer.get_char : AnsiChar;
var
  i: integer;
begin
  if (bufptr = 0) and not EOF(yyinput) then
  begin
    readln(yyinput, yyline);
    Inc(yylineno);
    yycolno := 1;
    buf[1]  := nl;
    for i := 1 to length(yyline) do
      buf[i + 1] := yyline[length(yyline) - i + 1];
    Inc(bufptr, length(yyline) + 1);
  end;
  if bufptr > 0 then
  begin
    Result := buf[bufptr];
    Dec(bufptr);
    Inc(yycolno);
  end
  else
    Result := #0;

end;

procedure TLexer.unget_char(c: AnsiChar);
begin
  if bufptr = max_chars then
    fatal('input buffer overflow');
  Inc(bufptr);
  Dec(yycolno);
  buf[bufptr] := c;
end;

procedure TLexer.put_char(c: AnsiChar);
begin
  if c = #0 then
  { ignore }
  else if c = nl then
    writeln(yyoutput)
  else
    Write(yyoutput, c)
end(*put_char*);

procedure TLexer.yyclear;
begin
  inherited;
  bufptr := 0;
end;

function TLexer.yywrap: boolean;
begin
  Close(yyinput);
  Close(yyoutput);
  Result := True;
end;

function TParser.parse() : integer;

var 
  yystate, yysp, yyn : Integer;
  yys : array [1..yymaxdepth] of Integer;
  yyv : array [1..yymaxdepth] of YYSType;
  yyval : YYSType;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)
// source: yyparse.cod line# 109
begin
  (* actions: *)
  case yyruleno of
1 : begin
         yyval := yyv[yysp-0];
       end;
2 : begin
         yyval := yyv[yysp-0];
       end;
3 : begin
         yyval := yyv[yysp-0];
       end;
4 : begin
         yyval := yyv[yysp-0];
       end;
5 : begin
         yyval := yyv[yysp-0];
       end;
6 : begin
         // source: ndyacc.y line#82
         yyerrok; 
       end;
7 : begin
         // source: ndyacc.y line#83
         yyerrok; 
       end;
8 : begin
         // source: ndyacc.y line#84
         yyerrok; 
       end;
9 : begin
         // source: ndyacc.y line#85
         yyerrok; 
       end;
10 : begin
         // source: ndyacc.y line#86
         yyerrok; 
       end;
11 : begin
         // source: ndyacc.y line#87
         yyerrok; 
       end;
12 : begin
         // source: ndyacc.y line#88
         yyerrok; 
       end;
13 : begin
         yyval := yyv[yysp-0];
       end;
14 : begin
         // source: ndyacc.y line#90
         yyerrok; 
       end;
15 : begin
         yyval := yyv[yysp-0];
       end;
16 : begin
         yyval := yyv[yysp-0];
       end;
17 : begin
         // source: ndyacc.y line#93
         error(rcurl_expected); 
       end;
18 : begin
         yyval := yyv[yysp-0];
       end;
19 : begin
         // source: ndyacc.y line#95
         yyerrok; 
       end;
20 : begin
         // source: ndyacc.y line#96
         yyerrok; 
       end;
21 : begin
         // source: ndyacc.y line#97
         yyerrok; 
       end;
22 : begin
         yyval := yyv[yysp-0];
       end;
23 : begin
         yyval := yyv[yysp-0];
       end;
24 : begin
         // source: ndyacc.y line#100
         error(rbrace_expected); 
       end;
25 : begin
         yyval := yyv[yysp-0];
       end;
26 : begin
         yyval := yyv[yysp-0];
       end;
27 : begin
         // source: ndyacc.y line#103
         error(rangle_expected); 
       end;
28 : begin
         yyval := yyv[yysp-0];
       end;
29 : begin
         // source: ndyacc.y line#109
         sort_types;
         definitions;
         next_section; 
       end;
30 : begin
         // source: ndyacc.y line#113
         next_section;
         generate_parser;
         next_section; 
       end;
31 : begin
         yyval := yyv[yysp-5];
       end;
32 : begin
       end;
33 : begin
         // source: ndyacc.y line#121
         copy_rest_of_file; 
       end;
34 : begin
       end;
35 : begin
         // source: ndyacc.y line#127
         yyerrok; 
       end;
36 : begin
         // source: ndyacc.y line#128
         error(error_in_def); 
       end;
37 : begin
         // source: ndyacc.y line#132
         startnt := ntsym(yyv[yysp-0]); 
       end;
38 : begin
         // source: ndyacc.y line#134
         error(ident_expected); 
       end;
39 : begin
         // source: ndyacc.y line#135
         copy_code; 
       end;
40 : begin
         yyval := yyv[yysp-2];
       end;
41 : begin
         // source: ndyacc.y line#138
         act_prec := 0; 
       end;
42 : begin
         yyval := yyv[yysp-3];
       end;
43 : begin
         // source: ndyacc.y line#141
         copy_union_code; 
       end;
44 : begin
         yyval := yyv[yysp-2];
       end;
45 : begin
         // source: ndyacc.y line#144
         act_prec := new_prec_level(left); 
       end;
46 : begin
         yyval := yyv[yysp-3];
       end;
47 : begin
         // source: ndyacc.y line#148
         act_prec := new_prec_level(right); 
       end;
48 : begin
         yyval := yyv[yysp-3];
       end;
49 : begin
         // source: ndyacc.y line#152
         act_prec := new_prec_level(nonassoc); 
       end;
50 : begin
         yyval := yyv[yysp-3];
       end;
51 : begin
         yyval := yyv[yysp-2];
       end;
52 : begin
         yyval := yyv[yysp-1];
       end;
53 : begin
         // source: ndyacc.y line#162
         act_type := 0; 
       end;
54 : begin
         // source: ndyacc.y line#164
         act_type := yyv[yysp-1]; add_type(yyv[yysp-1]); 
       end;
55 : begin
         yyval := yyv[yysp-0];
       end;
56 : begin
         // source: ndyacc.y line#170
         yyerrok; 
       end;
57 : begin
         // source: ndyacc.y line#172
         yyerrok; 
       end;
58 : begin
         // source: ndyacc.y line#174
         error(ident_expected); 
       end;
59 : begin
         // source: ndyacc.y line#176
         error(error_in_def); 
       end;
60 : begin
         // source: ndyacc.y line#178
         error(ident_expected); 
       end;
61 : begin
         // source: ndyacc.y line#182
         if act_type<>0 then
         sym_type^[yyv[yysp-0]] := act_type;
         if act_prec<>0 then
         sym_prec^[yyv[yysp-0]] := act_prec; 
       end;
62 : begin
         // source: ndyacc.y line#187
         litsym(yyv[yysp-0], 0);
         if act_type<>0 then
         sym_type^[litsym(yyv[yysp-0], 0)] := act_type;
         if act_prec<>0 then
         sym_prec^[litsym(yyv[yysp-0], 0)] := act_prec; 
       end;
63 : begin
         // source: ndyacc.y line#193
         litsym(yyv[yysp-0], 0);
         if act_type<>0 then
         sym_type^[litsym(yyv[yysp-0], 0)] := act_type;
         if act_prec<>0 then
         sym_prec^[litsym(yyv[yysp-0], 0)] := act_prec; 
       end;
64 : begin
         // source: ndyacc.y line#199
         litsym(yyv[yysp-1], 0);
         if act_type<>0 then
         sym_type^[litsym(yyv[yysp-1], yyv[yysp-0])] := act_type;
         if act_prec<>0 then
         sym_prec^[litsym(yyv[yysp-1], 0)]  := act_prec; 
       end;
65 : begin
         // source: ndyacc.y line#205
         litsym(yyv[yysp-1], 0);
         if act_type<>0 then
         sym_type^[litsym(yyv[yysp-1], yyv[yysp-0])] := act_type;
         if act_prec<>0 then
         sym_prec^[litsym(yyv[yysp-1], 0)]  := act_prec; 
       end;
66 : begin
         yyval := yyv[yysp-0];
       end;
67 : begin
         // source: ndyacc.y line#214
         yyerrok; 
       end;
68 : begin
         // source: ndyacc.y line#216
         yyerrok; 
       end;
69 : begin
         // source: ndyacc.y line#218
         error(ident_expected); 
       end;
70 : begin
         // source: ndyacc.y line#220
         error(error_in_def); 
       end;
71 : begin
         // source: ndyacc.y line#222
         error(ident_expected); 
       end;
72 : begin
         // source: ndyacc.y line#226
         if act_type<>0 then
         sym_type^[ntsym(yyv[yysp-0])] := act_type; 
       end;
73 : begin
         // source: ndyacc.y line#231
         next_section; 
       end;
74 : begin
         yyval := yyv[yysp-1];
       end;
75 : begin
         // source: ndyacc.y line#234
         copy_code; 
       end;
76 : begin
         // source: ndyacc.y line#235
         next_section; 
       end;
77 : begin
         yyval := yyv[yysp-4];
       end;
78 : begin
         // source: ndyacc.y line#241
         yyerrok; 
       end;
79 : begin
         // source: ndyacc.y line#243
         error(error_in_rule); 
       end;
80 : begin
         // source: ndyacc.y line#245
         error(error_in_rule); 
       end;
81 : begin
         // source: ndyacc.y line#249
         start_rule(ntsym(yyv[yysp-0])); 
       end;
82 : begin
         // source: ndyacc.y line#251
         start_body; 
       end;
83 : begin
         // source: ndyacc.y line#253
         end_body; 
       end;
84 : begin
         yyval := yyv[yysp-0];
       end;
85 : begin
         // source: ndyacc.y line#259
         start_body; 
       end;
86 : begin
         // source: ndyacc.y line#261
         end_body; 
       end;
87 : begin
       end;
88 : begin
         // source: ndyacc.y line#267
         add_symbol(yyv[yysp-0]); yyerrok; 
       end;
89 : begin
         // source: ndyacc.y line#269
         add_symbol(sym(yyv[yysp-0])); yyerrok; 
       end;
90 : begin
         // source: ndyacc.y line#271
         add_symbol(sym(yyv[yysp-0])); yyerrok; 
       end;
91 : begin
         // source: ndyacc.y line#273
         add_action; yyerrok; 
       end;
92 : begin
         // source: ndyacc.y line#275
         error(error_in_rule); 
       end;
93 : begin
         // source: ndyacc.y line#278
         copy_action; 
       end;
94 : begin
         yyval := yyv[yysp-2];
       end;
95 : begin
         // source: ndyacc.y line#280
         copy_single_action; 
       end;
96 : begin
       end;
97 : begin
         // source: ndyacc.y line#288
         add_rule_prec(yyv[yysp-0]); 
       end;
98 : begin
         yyval := yyv[yysp-3];
       end;
99 : begin
         // source: ndyacc.y line#292
         add_rule_prec(litsym(yyv[yysp-0], 0)); 
       end;
100 : begin
         yyval := yyv[yysp-3];
       end;
101 : begin
         // source: ndyacc.y line#296
         add_rule_prec(litsym(yyv[yysp-0], 0)); 
       end;
102 : begin
         yyval := yyv[yysp-3];
       end;
103 : begin
         yyval := yyv[yysp-1];
       end;
104 : begin
       end;
105 : begin
         // source: ndyacc.y line#306
         add_action; 
       end;
// source: yyparse.cod line# 113
  end;
end(*yyaction*);

(* parse table: *)

type YYARec = record
                sym, act : Integer;
              end;
     YYRRec = record
                len, sym : Integer;
              end;

const

yynacts   = 262;
yyngotos  = 148;
yynstates = 132;
yynrules  = 105;
yymaxtoken = 273;

yya : array [1..yynacts] of YYARec = (
{ 0: }
{ 1: }
  ( sym: 256; act: 13 ),
  ( sym: 262; act: 14 ),
  ( sym: 263; act: 15 ),
  ( sym: 264; act: 16 ),
  ( sym: 265; act: 17 ),
  ( sym: 266; act: 18 ),
  ( sym: 267; act: 19 ),
  ( sym: 269; act: 20 ),
  ( sym: 270; act: 21 ),
  ( sym: 271; act: 22 ),
{ 2: }
  ( sym: 0; act: 0 ),
{ 3: }
{ 4: }
{ 5: }
{ 6: }
  ( sym: 256; act: 26 ),
  ( sym: 257; act: 27 ),
{ 7: }
  ( sym: 60; act: 30 ),
  ( sym: 256; act: -53 ),
  ( sym: 257; act: -53 ),
  ( sym: 262; act: -53 ),
  ( sym: 263; act: -53 ),
  ( sym: 264; act: -53 ),
  ( sym: 265; act: -53 ),
  ( sym: 266; act: -53 ),
  ( sym: 267; act: -53 ),
  ( sym: 269; act: -53 ),
  ( sym: 270; act: -53 ),
  ( sym: 271; act: -53 ),
{ 8: }
{ 9: }
{ 10: }
{ 11: }
{ 12: }
{ 13: }
{ 14: }
{ 15: }
{ 16: }
{ 17: }
{ 18: }
{ 19: }
{ 20: }
{ 21: }
{ 22: }
{ 23: }
  ( sym: 256; act: 37 ),
  ( sym: 272; act: 38 ),
{ 24: }
  ( sym: 256; act: 42 ),
  ( sym: 271; act: 22 ),
  ( sym: 258; act: -73 ),
{ 25: }
{ 26: }
{ 27: }
{ 28: }
  ( sym: 256; act: 46 ),
  ( sym: 257; act: 27 ),
  ( sym: 262; act: -52 ),
  ( sym: 263; act: -52 ),
  ( sym: 264; act: -52 ),
  ( sym: 265; act: -52 ),
  ( sym: 266; act: -52 ),
  ( sym: 267; act: -52 ),
  ( sym: 269; act: -52 ),
  ( sym: 270; act: -52 ),
  ( sym: 271; act: -52 ),
{ 29: }
  ( sym: 257; act: 27 ),
{ 30: }
{ 31: }
  ( sym: 60; act: 30 ),
  ( sym: 256; act: -53 ),
  ( sym: 257; act: -53 ),
  ( sym: 259; act: -53 ),
  ( sym: 260; act: -53 ),
{ 32: }
  ( sym: 60; act: 30 ),
  ( sym: 256; act: -53 ),
  ( sym: 257; act: -53 ),
  ( sym: 259; act: -53 ),
  ( sym: 260; act: -53 ),
{ 33: }
  ( sym: 60; act: 30 ),
  ( sym: 256; act: -53 ),
  ( sym: 257; act: -53 ),
  ( sym: 259; act: -53 ),
  ( sym: 260; act: -53 ),
{ 34: }
  ( sym: 125; act: 51 ),
{ 35: }
  ( sym: 60; act: 30 ),
  ( sym: 256; act: -53 ),
  ( sym: 257; act: -53 ),
  ( sym: 259; act: -53 ),
  ( sym: 260; act: -53 ),
{ 36: }
{ 37: }
{ 38: }
{ 39: }
  ( sym: 258; act: 55 ),
{ 40: }
  ( sym: 124; act: 60 ),
  ( sym: 256; act: 61 ),
  ( sym: 258; act: 55 ),
  ( sym: 0; act: -30 ),
  ( sym: 270; act: -30 ),
{ 41: }
{ 42: }
{ 43: }
{ 44: }
  ( sym: 44; act: 65 ),
  ( sym: 256; act: 66 ),
  ( sym: 257; act: 27 ),
  ( sym: 262; act: -51 ),
  ( sym: 263; act: -51 ),
  ( sym: 264; act: -51 ),
  ( sym: 265; act: -51 ),
  ( sym: 266; act: -51 ),
  ( sym: 267; act: -51 ),
  ( sym: 269; act: -51 ),
  ( sym: 270; act: -51 ),
  ( sym: 271; act: -51 ),
{ 45: }
{ 46: }
{ 47: }
  ( sym: 62; act: 68 ),
  ( sym: 256; act: 69 ),
{ 48: }
  ( sym: 256; act: 75 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
{ 49: }
  ( sym: 256; act: 75 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
{ 50: }
  ( sym: 256; act: 75 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
{ 51: }
{ 52: }
  ( sym: 256; act: 75 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
{ 53: }
{ 54: }
{ 55: }
{ 56: }
{ 57: }
{ 58: }
  ( sym: 270; act: 21 ),
  ( sym: 0; act: -32 ),
{ 59: }
{ 60: }
{ 61: }
{ 62: }
  ( sym: 256; act: 37 ),
  ( sym: 272; act: 38 ),
{ 63: }
{ 64: }
  ( sym: 256; act: 87 ),
  ( sym: 257; act: 27 ),
{ 65: }
{ 66: }
{ 67: }
{ 68: }
{ 69: }
{ 70: }
{ 71: }
  ( sym: 44; act: 65 ),
  ( sym: 256; act: 90 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
  ( sym: 262; act: -50 ),
  ( sym: 263; act: -50 ),
  ( sym: 264; act: -50 ),
  ( sym: 265; act: -50 ),
  ( sym: 266; act: -50 ),
  ( sym: 267; act: -50 ),
  ( sym: 269; act: -50 ),
  ( sym: 270; act: -50 ),
  ( sym: 271; act: -50 ),
{ 72: }
  ( sym: 261; act: 92 ),
  ( sym: 44; act: -62 ),
  ( sym: 256; act: -62 ),
  ( sym: 257; act: -62 ),
  ( sym: 259; act: -62 ),
  ( sym: 260; act: -62 ),
  ( sym: 262; act: -62 ),
  ( sym: 263; act: -62 ),
  ( sym: 264; act: -62 ),
  ( sym: 265; act: -62 ),
  ( sym: 266; act: -62 ),
  ( sym: 267; act: -62 ),
  ( sym: 269; act: -62 ),
  ( sym: 270; act: -62 ),
  ( sym: 271; act: -62 ),
{ 73: }
{ 74: }
  ( sym: 261; act: 92 ),
  ( sym: 44; act: -63 ),
  ( sym: 256; act: -63 ),
  ( sym: 257; act: -63 ),
  ( sym: 259; act: -63 ),
  ( sym: 260; act: -63 ),
  ( sym: 262; act: -63 ),
  ( sym: 263; act: -63 ),
  ( sym: 264; act: -63 ),
  ( sym: 265; act: -63 ),
  ( sym: 266; act: -63 ),
  ( sym: 267; act: -63 ),
  ( sym: 269; act: -63 ),
  ( sym: 270; act: -63 ),
  ( sym: 271; act: -63 ),
{ 75: }
{ 76: }
{ 77: }
{ 78: }
  ( sym: 44; act: 65 ),
  ( sym: 256; act: 90 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
  ( sym: 262; act: -48 ),
  ( sym: 263; act: -48 ),
  ( sym: 264; act: -48 ),
  ( sym: 265; act: -48 ),
  ( sym: 266; act: -48 ),
  ( sym: 267; act: -48 ),
  ( sym: 269; act: -48 ),
  ( sym: 270; act: -48 ),
  ( sym: 271; act: -48 ),
{ 79: }
  ( sym: 44; act: 65 ),
  ( sym: 256; act: 90 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
  ( sym: 262; act: -46 ),
  ( sym: 263; act: -46 ),
  ( sym: 264; act: -46 ),
  ( sym: 265; act: -46 ),
  ( sym: 266; act: -46 ),
  ( sym: 267; act: -46 ),
  ( sym: 269; act: -46 ),
  ( sym: 270; act: -46 ),
  ( sym: 271; act: -46 ),
{ 80: }
  ( sym: 44; act: 65 ),
  ( sym: 256; act: 90 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
  ( sym: 262; act: -42 ),
  ( sym: 263; act: -42 ),
  ( sym: 264; act: -42 ),
  ( sym: 265; act: -42 ),
  ( sym: 266; act: -42 ),
  ( sym: 267; act: -42 ),
  ( sym: 269; act: -42 ),
  ( sym: 270; act: -42 ),
  ( sym: 271; act: -42 ),
{ 81: }
  ( sym: 58; act: 95 ),
{ 82: }
{ 83: }
{ 84: }
{ 85: }
{ 86: }
{ 87: }
{ 88: }
{ 89: }
  ( sym: 256; act: 99 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
{ 90: }
{ 91: }
{ 92: }
{ 93: }
{ 94: }
{ 95: }
{ 96: }
  ( sym: 61; act: 109 ),
  ( sym: 123; act: 110 ),
  ( sym: 256; act: 111 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
  ( sym: 268; act: 112 ),
  ( sym: 0; act: -96 ),
  ( sym: 59; act: -96 ),
  ( sym: 124; act: -96 ),
  ( sym: 258; act: -96 ),
  ( sym: 270; act: -96 ),
{ 97: }
  ( sym: 258; act: 55 ),
{ 98: }
{ 99: }
{ 100: }
{ 101: }
{ 102: }
  ( sym: 59; act: 116 ),
  ( sym: 0; act: -86 ),
  ( sym: 124; act: -86 ),
  ( sym: 256; act: -86 ),
  ( sym: 258; act: -86 ),
  ( sym: 270; act: -86 ),
{ 103: }
{ 104: }
{ 105: }
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
{ 106: }
{ 107: }
{ 108: }
{ 109: }
{ 110: }
{ 111: }
{ 112: }
{ 113: }
{ 114: }
  ( sym: 61; act: 109 ),
  ( sym: 123; act: 110 ),
  ( sym: 256; act: 111 ),
  ( sym: 257; act: 27 ),
  ( sym: 259; act: 76 ),
  ( sym: 260; act: 77 ),
  ( sym: 268; act: 112 ),
  ( sym: 0; act: -96 ),
  ( sym: 59; act: -96 ),
  ( sym: 124; act: -96 ),
  ( sym: 258; act: -96 ),
  ( sym: 270; act: -96 ),
{ 115: }
{ 116: }
{ 117: }
  ( sym: 125; act: 123 ),
  ( sym: 256; act: 124 ),
{ 118: }
{ 119: }
{ 120: }
{ 121: }
  ( sym: 59; act: 116 ),
  ( sym: 0; act: -83 ),
  ( sym: 124; act: -83 ),
  ( sym: 256; act: -83 ),
  ( sym: 258; act: -83 ),
  ( sym: 270; act: -83 ),
{ 122: }
{ 123: }
{ 124: }
{ 125: }
  ( sym: 61; act: 109 ),
  ( sym: 123; act: 110 ),
  ( sym: 0; act: -104 ),
  ( sym: 59; act: -104 ),
  ( sym: 124; act: -104 ),
  ( sym: 256; act: -104 ),
  ( sym: 258; act: -104 ),
  ( sym: 270; act: -104 ),
{ 126: }
  ( sym: 61; act: 109 ),
  ( sym: 123; act: 110 ),
  ( sym: 0; act: -104 ),
  ( sym: 59; act: -104 ),
  ( sym: 124; act: -104 ),
  ( sym: 256; act: -104 ),
  ( sym: 258; act: -104 ),
  ( sym: 270; act: -104 ),
{ 127: }
  ( sym: 61; act: 109 ),
  ( sym: 123; act: 110 ),
  ( sym: 0; act: -104 ),
  ( sym: 59; act: -104 ),
  ( sym: 124; act: -104 ),
  ( sym: 256; act: -104 ),
  ( sym: 258; act: -104 ),
  ( sym: 270; act: -104 )
{ 128: }
{ 129: }
{ 130: }
{ 131: }
);

yyg : array [1..yyngotos] of YYARec = (
{ 0: }
  ( sym: -28; act: 1 ),
  ( sym: -2; act: 2 ),
{ 1: }
  ( sym: -33; act: 3 ),
  ( sym: -17; act: 4 ),
  ( sym: -16; act: 5 ),
  ( sym: -14; act: 6 ),
  ( sym: -13; act: 7 ),
  ( sym: -12; act: 8 ),
  ( sym: -11; act: 9 ),
  ( sym: -10; act: 10 ),
  ( sym: -9; act: 11 ),
  ( sym: -8; act: 12 ),
{ 2: }
{ 3: }
{ 4: }
  ( sym: -34; act: 23 ),
{ 5: }
  ( sym: -30; act: 24 ),
{ 6: }
  ( sym: -3; act: 25 ),
{ 7: }
  ( sym: -35; act: 28 ),
  ( sym: -25; act: 29 ),
{ 8: }
  ( sym: -41; act: 31 ),
{ 9: }
  ( sym: -40; act: 32 ),
{ 10: }
  ( sym: -39; act: 33 ),
{ 11: }
  ( sym: -38; act: 34 ),
{ 12: }
  ( sym: -36; act: 35 ),
{ 13: }
{ 14: }
{ 15: }
{ 16: }
{ 17: }
{ 18: }
{ 19: }
{ 20: }
{ 21: }
{ 22: }
{ 23: }
  ( sym: -18; act: 36 ),
{ 24: }
  ( sym: -46; act: 39 ),
  ( sym: -29; act: 40 ),
  ( sym: -17; act: 41 ),
{ 25: }
{ 26: }
{ 27: }
{ 28: }
  ( sym: -44; act: 43 ),
  ( sym: -42; act: 44 ),
  ( sym: -3; act: 45 ),
{ 29: }
  ( sym: -3; act: 47 ),
{ 30: }
{ 31: }
  ( sym: -35; act: 48 ),
  ( sym: -25; act: 29 ),
{ 32: }
  ( sym: -35; act: 49 ),
  ( sym: -25; act: 29 ),
{ 33: }
  ( sym: -35; act: 50 ),
  ( sym: -25; act: 29 ),
{ 34: }
{ 35: }
  ( sym: -35; act: 52 ),
  ( sym: -25; act: 29 ),
{ 36: }
{ 37: }
{ 38: }
{ 39: }
  ( sym: -45; act: 53 ),
  ( sym: -4; act: 54 ),
{ 40: }
  ( sym: -49; act: 56 ),
  ( sym: -45; act: 57 ),
  ( sym: -32; act: 58 ),
  ( sym: -22; act: 59 ),
  ( sym: -4; act: 54 ),
{ 41: }
  ( sym: -47; act: 62 ),
{ 42: }
{ 43: }
{ 44: }
  ( sym: -44; act: 63 ),
  ( sym: -19; act: 64 ),
  ( sym: -3; act: 45 ),
{ 45: }
{ 46: }
{ 47: }
  ( sym: -26; act: 67 ),
{ 48: }
  ( sym: -43; act: 70 ),
  ( sym: -37; act: 71 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 49: }
  ( sym: -43; act: 70 ),
  ( sym: -37; act: 78 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 50: }
  ( sym: -43; act: 70 ),
  ( sym: -37; act: 79 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 51: }
{ 52: }
  ( sym: -43; act: 70 ),
  ( sym: -37; act: 80 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 53: }
{ 54: }
  ( sym: -50; act: 81 ),
{ 55: }
{ 56: }
{ 57: }
{ 58: }
  ( sym: -31; act: 82 ),
  ( sym: -16; act: 83 ),
{ 59: }
  ( sym: -54; act: 84 ),
{ 60: }
{ 61: }
{ 62: }
  ( sym: -18; act: 85 ),
{ 63: }
{ 64: }
  ( sym: -44; act: 86 ),
  ( sym: -3; act: 45 ),
{ 65: }
{ 66: }
{ 67: }
{ 68: }
{ 69: }
{ 70: }
{ 71: }
  ( sym: -43; act: 88 ),
  ( sym: -19; act: 89 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 72: }
  ( sym: -7; act: 91 ),
{ 73: }
{ 74: }
  ( sym: -7; act: 93 ),
{ 75: }
{ 76: }
{ 77: }
{ 78: }
  ( sym: -43; act: 88 ),
  ( sym: -19; act: 89 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 79: }
  ( sym: -43; act: 88 ),
  ( sym: -19; act: 89 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 80: }
  ( sym: -43; act: 88 ),
  ( sym: -19; act: 89 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 81: }
  ( sym: -20; act: 94 ),
{ 82: }
{ 83: }
{ 84: }
  ( sym: -51; act: 96 ),
{ 85: }
  ( sym: -48; act: 97 ),
{ 86: }
{ 87: }
{ 88: }
{ 89: }
  ( sym: -43; act: 98 ),
  ( sym: -6; act: 72 ),
  ( sym: -5; act: 73 ),
  ( sym: -3; act: 74 ),
{ 90: }
{ 91: }
{ 92: }
{ 93: }
{ 94: }
  ( sym: -52; act: 100 ),
{ 95: }
{ 96: }
  ( sym: -55; act: 101 ),
  ( sym: -53; act: 102 ),
  ( sym: -27; act: 103 ),
  ( sym: -23; act: 104 ),
  ( sym: -15; act: 105 ),
  ( sym: -6; act: 106 ),
  ( sym: -5; act: 107 ),
  ( sym: -3; act: 108 ),
{ 97: }
  ( sym: -45; act: 113 ),
  ( sym: -4; act: 54 ),
{ 98: }
{ 99: }
{ 100: }
  ( sym: -51; act: 114 ),
{ 101: }
{ 102: }
  ( sym: -21; act: 115 ),
{ 103: }
{ 104: }
  ( sym: -56; act: 117 ),
{ 105: }
  ( sym: -6; act: 118 ),
  ( sym: -5; act: 119 ),
  ( sym: -3; act: 120 ),
{ 106: }
{ 107: }
{ 108: }
{ 109: }
{ 110: }
{ 111: }
{ 112: }
{ 113: }
{ 114: }
  ( sym: -55; act: 101 ),
  ( sym: -53; act: 121 ),
  ( sym: -27; act: 103 ),
  ( sym: -23; act: 104 ),
  ( sym: -15; act: 105 ),
  ( sym: -6; act: 106 ),
  ( sym: -5; act: 107 ),
  ( sym: -3; act: 108 ),
{ 115: }
{ 116: }
{ 117: }
  ( sym: -24; act: 122 ),
{ 118: }
  ( sym: -59; act: 125 ),
{ 119: }
  ( sym: -58; act: 126 ),
{ 120: }
  ( sym: -60; act: 127 ),
{ 121: }
  ( sym: -21; act: 115 ),
{ 122: }
{ 123: }
{ 124: }
{ 125: }
  ( sym: -57; act: 128 ),
  ( sym: -55; act: 129 ),
  ( sym: -27; act: 103 ),
  ( sym: -23; act: 104 ),
{ 126: }
  ( sym: -57; act: 130 ),
  ( sym: -55; act: 129 ),
  ( sym: -27; act: 103 ),
  ( sym: -23; act: 104 ),
{ 127: }
  ( sym: -57; act: 131 ),
  ( sym: -55; act: 129 ),
  ( sym: -27; act: 103 ),
  ( sym: -23; act: 104 )
{ 128: }
{ 129: }
{ 130: }
{ 131: }
);

yyd : array [0..yynstates-1] of Integer = (
{ 0: } -34,
{ 1: } 0,
{ 2: } 0,
{ 3: } -35,
{ 4: } -39,
{ 5: } -29,
{ 6: } 0,
{ 7: } 0,
{ 8: } -49,
{ 9: } -47,
{ 10: } -45,
{ 11: } -43,
{ 12: } -41,
{ 13: } -36,
{ 14: } -6,
{ 15: } -8,
{ 16: } -9,
{ 17: } -10,
{ 18: } -11,
{ 19: } -12,
{ 20: } -7,
{ 21: } -14,
{ 22: } -15,
{ 23: } 0,
{ 24: } 0,
{ 25: } -37,
{ 26: } -38,
{ 27: } -1,
{ 28: } 0,
{ 29: } 0,
{ 30: } -25,
{ 31: } 0,
{ 32: } 0,
{ 33: } 0,
{ 34: } 0,
{ 35: } 0,
{ 36: } -40,
{ 37: } -17,
{ 38: } -16,
{ 39: } 0,
{ 40: } 0,
{ 41: } -75,
{ 42: } -79,
{ 43: } -66,
{ 44: } 0,
{ 45: } -72,
{ 46: } -69,
{ 47: } 0,
{ 48: } 0,
{ 49: } 0,
{ 50: } 0,
{ 51: } -44,
{ 52: } 0,
{ 53: } -74,
{ 54: } -81,
{ 55: } -2,
{ 56: } -78,
{ 57: } -84,
{ 58: } 0,
{ 59: } -85,
{ 60: } -21,
{ 61: } -80,
{ 62: } 0,
{ 63: } -67,
{ 64: } 0,
{ 65: } -18,
{ 66: } -70,
{ 67: } -54,
{ 68: } -26,
{ 69: } -27,
{ 70: } -55,
{ 71: } 0,
{ 72: } 0,
{ 73: } -61,
{ 74: } 0,
{ 75: } -58,
{ 76: } -3,
{ 77: } -4,
{ 78: } 0,
{ 79: } 0,
{ 80: } 0,
{ 81: } 0,
{ 82: } -31,
{ 83: } -33,
{ 84: } -87,
{ 85: } -76,
{ 86: } -68,
{ 87: } -71,
{ 88: } -56,
{ 89: } 0,
{ 90: } -59,
{ 91: } -64,
{ 92: } -5,
{ 93: } -65,
{ 94: } -82,
{ 95: } -19,
{ 96: } 0,
{ 97: } 0,
{ 98: } -57,
{ 99: } -60,
{ 100: } -87,
{ 101: } -91,
{ 102: } 0,
{ 103: } -95,
{ 104: } -93,
{ 105: } 0,
{ 106: } -89,
{ 107: } -88,
{ 108: } -90,
{ 109: } -28,
{ 110: } -22,
{ 111: } -92,
{ 112: } -13,
{ 113: } -77,
{ 114: } 0,
{ 115: } -103,
{ 116: } -20,
{ 117: } 0,
{ 118: } -99,
{ 119: } -97,
{ 120: } -101,
{ 121: } 0,
{ 122: } -94,
{ 123: } -23,
{ 124: } -24,
{ 125: } 0,
{ 126: } 0,
{ 127: } 0,
{ 128: } -100,
{ 129: } -105,
{ 130: } -98,
{ 131: } -102
);

yyal : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 11,
{ 3: } 12,
{ 4: } 12,
{ 5: } 12,
{ 6: } 12,
{ 7: } 14,
{ 8: } 26,
{ 9: } 26,
{ 10: } 26,
{ 11: } 26,
{ 12: } 26,
{ 13: } 26,
{ 14: } 26,
{ 15: } 26,
{ 16: } 26,
{ 17: } 26,
{ 18: } 26,
{ 19: } 26,
{ 20: } 26,
{ 21: } 26,
{ 22: } 26,
{ 23: } 26,
{ 24: } 28,
{ 25: } 31,
{ 26: } 31,
{ 27: } 31,
{ 28: } 31,
{ 29: } 42,
{ 30: } 43,
{ 31: } 43,
{ 32: } 48,
{ 33: } 53,
{ 34: } 58,
{ 35: } 59,
{ 36: } 64,
{ 37: } 64,
{ 38: } 64,
{ 39: } 64,
{ 40: } 65,
{ 41: } 70,
{ 42: } 70,
{ 43: } 70,
{ 44: } 70,
{ 45: } 82,
{ 46: } 82,
{ 47: } 82,
{ 48: } 84,
{ 49: } 88,
{ 50: } 92,
{ 51: } 96,
{ 52: } 96,
{ 53: } 100,
{ 54: } 100,
{ 55: } 100,
{ 56: } 100,
{ 57: } 100,
{ 58: } 100,
{ 59: } 102,
{ 60: } 102,
{ 61: } 102,
{ 62: } 102,
{ 63: } 104,
{ 64: } 104,
{ 65: } 106,
{ 66: } 106,
{ 67: } 106,
{ 68: } 106,
{ 69: } 106,
{ 70: } 106,
{ 71: } 106,
{ 72: } 120,
{ 73: } 135,
{ 74: } 135,
{ 75: } 150,
{ 76: } 150,
{ 77: } 150,
{ 78: } 150,
{ 79: } 164,
{ 80: } 178,
{ 81: } 192,
{ 82: } 193,
{ 83: } 193,
{ 84: } 193,
{ 85: } 193,
{ 86: } 193,
{ 87: } 193,
{ 88: } 193,
{ 89: } 193,
{ 90: } 197,
{ 91: } 197,
{ 92: } 197,
{ 93: } 197,
{ 94: } 197,
{ 95: } 197,
{ 96: } 197,
{ 97: } 209,
{ 98: } 210,
{ 99: } 210,
{ 100: } 210,
{ 101: } 210,
{ 102: } 210,
{ 103: } 216,
{ 104: } 216,
{ 105: } 216,
{ 106: } 219,
{ 107: } 219,
{ 108: } 219,
{ 109: } 219,
{ 110: } 219,
{ 111: } 219,
{ 112: } 219,
{ 113: } 219,
{ 114: } 219,
{ 115: } 231,
{ 116: } 231,
{ 117: } 231,
{ 118: } 233,
{ 119: } 233,
{ 120: } 233,
{ 121: } 233,
{ 122: } 239,
{ 123: } 239,
{ 124: } 239,
{ 125: } 239,
{ 126: } 247,
{ 127: } 255,
{ 128: } 263,
{ 129: } 263,
{ 130: } 263,
{ 131: } 263
);

yyah : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 10,
{ 2: } 11,
{ 3: } 11,
{ 4: } 11,
{ 5: } 11,
{ 6: } 13,
{ 7: } 25,
{ 8: } 25,
{ 9: } 25,
{ 10: } 25,
{ 11: } 25,
{ 12: } 25,
{ 13: } 25,
{ 14: } 25,
{ 15: } 25,
{ 16: } 25,
{ 17: } 25,
{ 18: } 25,
{ 19: } 25,
{ 20: } 25,
{ 21: } 25,
{ 22: } 25,
{ 23: } 27,
{ 24: } 30,
{ 25: } 30,
{ 26: } 30,
{ 27: } 30,
{ 28: } 41,
{ 29: } 42,
{ 30: } 42,
{ 31: } 47,
{ 32: } 52,
{ 33: } 57,
{ 34: } 58,
{ 35: } 63,
{ 36: } 63,
{ 37: } 63,
{ 38: } 63,
{ 39: } 64,
{ 40: } 69,
{ 41: } 69,
{ 42: } 69,
{ 43: } 69,
{ 44: } 81,
{ 45: } 81,
{ 46: } 81,
{ 47: } 83,
{ 48: } 87,
{ 49: } 91,
{ 50: } 95,
{ 51: } 95,
{ 52: } 99,
{ 53: } 99,
{ 54: } 99,
{ 55: } 99,
{ 56: } 99,
{ 57: } 99,
{ 58: } 101,
{ 59: } 101,
{ 60: } 101,
{ 61: } 101,
{ 62: } 103,
{ 63: } 103,
{ 64: } 105,
{ 65: } 105,
{ 66: } 105,
{ 67: } 105,
{ 68: } 105,
{ 69: } 105,
{ 70: } 105,
{ 71: } 119,
{ 72: } 134,
{ 73: } 134,
{ 74: } 149,
{ 75: } 149,
{ 76: } 149,
{ 77: } 149,
{ 78: } 163,
{ 79: } 177,
{ 80: } 191,
{ 81: } 192,
{ 82: } 192,
{ 83: } 192,
{ 84: } 192,
{ 85: } 192,
{ 86: } 192,
{ 87: } 192,
{ 88: } 192,
{ 89: } 196,
{ 90: } 196,
{ 91: } 196,
{ 92: } 196,
{ 93: } 196,
{ 94: } 196,
{ 95: } 196,
{ 96: } 208,
{ 97: } 209,
{ 98: } 209,
{ 99: } 209,
{ 100: } 209,
{ 101: } 209,
{ 102: } 215,
{ 103: } 215,
{ 104: } 215,
{ 105: } 218,
{ 106: } 218,
{ 107: } 218,
{ 108: } 218,
{ 109: } 218,
{ 110: } 218,
{ 111: } 218,
{ 112: } 218,
{ 113: } 218,
{ 114: } 230,
{ 115: } 230,
{ 116: } 230,
{ 117: } 232,
{ 118: } 232,
{ 119: } 232,
{ 120: } 232,
{ 121: } 238,
{ 122: } 238,
{ 123: } 238,
{ 124: } 238,
{ 125: } 246,
{ 126: } 254,
{ 127: } 262,
{ 128: } 262,
{ 129: } 262,
{ 130: } 262,
{ 131: } 262
);

yygl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 3,
{ 2: } 13,
{ 3: } 13,
{ 4: } 13,
{ 5: } 14,
{ 6: } 15,
{ 7: } 16,
{ 8: } 18,
{ 9: } 19,
{ 10: } 20,
{ 11: } 21,
{ 12: } 22,
{ 13: } 23,
{ 14: } 23,
{ 15: } 23,
{ 16: } 23,
{ 17: } 23,
{ 18: } 23,
{ 19: } 23,
{ 20: } 23,
{ 21: } 23,
{ 22: } 23,
{ 23: } 23,
{ 24: } 24,
{ 25: } 27,
{ 26: } 27,
{ 27: } 27,
{ 28: } 27,
{ 29: } 30,
{ 30: } 31,
{ 31: } 31,
{ 32: } 33,
{ 33: } 35,
{ 34: } 37,
{ 35: } 37,
{ 36: } 39,
{ 37: } 39,
{ 38: } 39,
{ 39: } 39,
{ 40: } 41,
{ 41: } 46,
{ 42: } 47,
{ 43: } 47,
{ 44: } 47,
{ 45: } 50,
{ 46: } 50,
{ 47: } 50,
{ 48: } 51,
{ 49: } 56,
{ 50: } 61,
{ 51: } 66,
{ 52: } 66,
{ 53: } 71,
{ 54: } 71,
{ 55: } 72,
{ 56: } 72,
{ 57: } 72,
{ 58: } 72,
{ 59: } 74,
{ 60: } 75,
{ 61: } 75,
{ 62: } 75,
{ 63: } 76,
{ 64: } 76,
{ 65: } 78,
{ 66: } 78,
{ 67: } 78,
{ 68: } 78,
{ 69: } 78,
{ 70: } 78,
{ 71: } 78,
{ 72: } 83,
{ 73: } 84,
{ 74: } 84,
{ 75: } 85,
{ 76: } 85,
{ 77: } 85,
{ 78: } 85,
{ 79: } 90,
{ 80: } 95,
{ 81: } 100,
{ 82: } 101,
{ 83: } 101,
{ 84: } 101,
{ 85: } 102,
{ 86: } 103,
{ 87: } 103,
{ 88: } 103,
{ 89: } 103,
{ 90: } 107,
{ 91: } 107,
{ 92: } 107,
{ 93: } 107,
{ 94: } 107,
{ 95: } 108,
{ 96: } 108,
{ 97: } 116,
{ 98: } 118,
{ 99: } 118,
{ 100: } 118,
{ 101: } 119,
{ 102: } 119,
{ 103: } 120,
{ 104: } 120,
{ 105: } 121,
{ 106: } 124,
{ 107: } 124,
{ 108: } 124,
{ 109: } 124,
{ 110: } 124,
{ 111: } 124,
{ 112: } 124,
{ 113: } 124,
{ 114: } 124,
{ 115: } 132,
{ 116: } 132,
{ 117: } 132,
{ 118: } 133,
{ 119: } 134,
{ 120: } 135,
{ 121: } 136,
{ 122: } 137,
{ 123: } 137,
{ 124: } 137,
{ 125: } 137,
{ 126: } 141,
{ 127: } 145,
{ 128: } 149,
{ 129: } 149,
{ 130: } 149,
{ 131: } 149
);

yygh : array [0..yynstates-1] of Integer = (
{ 0: } 2,
{ 1: } 12,
{ 2: } 12,
{ 3: } 12,
{ 4: } 13,
{ 5: } 14,
{ 6: } 15,
{ 7: } 17,
{ 8: } 18,
{ 9: } 19,
{ 10: } 20,
{ 11: } 21,
{ 12: } 22,
{ 13: } 22,
{ 14: } 22,
{ 15: } 22,
{ 16: } 22,
{ 17: } 22,
{ 18: } 22,
{ 19: } 22,
{ 20: } 22,
{ 21: } 22,
{ 22: } 22,
{ 23: } 23,
{ 24: } 26,
{ 25: } 26,
{ 26: } 26,
{ 27: } 26,
{ 28: } 29,
{ 29: } 30,
{ 30: } 30,
{ 31: } 32,
{ 32: } 34,
{ 33: } 36,
{ 34: } 36,
{ 35: } 38,
{ 36: } 38,
{ 37: } 38,
{ 38: } 38,
{ 39: } 40,
{ 40: } 45,
{ 41: } 46,
{ 42: } 46,
{ 43: } 46,
{ 44: } 49,
{ 45: } 49,
{ 46: } 49,
{ 47: } 50,
{ 48: } 55,
{ 49: } 60,
{ 50: } 65,
{ 51: } 65,
{ 52: } 70,
{ 53: } 70,
{ 54: } 71,
{ 55: } 71,
{ 56: } 71,
{ 57: } 71,
{ 58: } 73,
{ 59: } 74,
{ 60: } 74,
{ 61: } 74,
{ 62: } 75,
{ 63: } 75,
{ 64: } 77,
{ 65: } 77,
{ 66: } 77,
{ 67: } 77,
{ 68: } 77,
{ 69: } 77,
{ 70: } 77,
{ 71: } 82,
{ 72: } 83,
{ 73: } 83,
{ 74: } 84,
{ 75: } 84,
{ 76: } 84,
{ 77: } 84,
{ 78: } 89,
{ 79: } 94,
{ 80: } 99,
{ 81: } 100,
{ 82: } 100,
{ 83: } 100,
{ 84: } 101,
{ 85: } 102,
{ 86: } 102,
{ 87: } 102,
{ 88: } 102,
{ 89: } 106,
{ 90: } 106,
{ 91: } 106,
{ 92: } 106,
{ 93: } 106,
{ 94: } 107,
{ 95: } 107,
{ 96: } 115,
{ 97: } 117,
{ 98: } 117,
{ 99: } 117,
{ 100: } 118,
{ 101: } 118,
{ 102: } 119,
{ 103: } 119,
{ 104: } 120,
{ 105: } 123,
{ 106: } 123,
{ 107: } 123,
{ 108: } 123,
{ 109: } 123,
{ 110: } 123,
{ 111: } 123,
{ 112: } 123,
{ 113: } 123,
{ 114: } 131,
{ 115: } 131,
{ 116: } 131,
{ 117: } 132,
{ 118: } 133,
{ 119: } 134,
{ 120: } 135,
{ 121: } 136,
{ 122: } 136,
{ 123: } 136,
{ 124: } 136,
{ 125: } 140,
{ 126: } 144,
{ 127: } 148,
{ 128: } 148,
{ 129: } 148,
{ 130: } 148,
{ 131: } 148
);

yyr : array [1..yynrules] of YYRRec = (
{ 1: } ( len: 1; sym: -3 ),
{ 2: } ( len: 1; sym: -4 ),
{ 3: } ( len: 1; sym: -5 ),
{ 4: } ( len: 1; sym: -6 ),
{ 5: } ( len: 1; sym: -7 ),
{ 6: } ( len: 1; sym: -8 ),
{ 7: } ( len: 1; sym: -9 ),
{ 8: } ( len: 1; sym: -10 ),
{ 9: } ( len: 1; sym: -11 ),
{ 10: } ( len: 1; sym: -12 ),
{ 11: } ( len: 1; sym: -13 ),
{ 12: } ( len: 1; sym: -14 ),
{ 13: } ( len: 1; sym: -15 ),
{ 14: } ( len: 1; sym: -16 ),
{ 15: } ( len: 1; sym: -17 ),
{ 16: } ( len: 1; sym: -18 ),
{ 17: } ( len: 1; sym: -18 ),
{ 18: } ( len: 1; sym: -19 ),
{ 19: } ( len: 1; sym: -20 ),
{ 20: } ( len: 1; sym: -21 ),
{ 21: } ( len: 1; sym: -22 ),
{ 22: } ( len: 1; sym: -23 ),
{ 23: } ( len: 1; sym: -24 ),
{ 24: } ( len: 1; sym: -24 ),
{ 25: } ( len: 1; sym: -25 ),
{ 26: } ( len: 1; sym: -26 ),
{ 27: } ( len: 1; sym: -26 ),
{ 28: } ( len: 1; sym: -27 ),
{ 29: } ( len: 0; sym: -30 ),
{ 30: } ( len: 0; sym: -32 ),
{ 31: } ( len: 6; sym: -2 ),
{ 32: } ( len: 0; sym: -31 ),
{ 33: } ( len: 1; sym: -31 ),
{ 34: } ( len: 0; sym: -28 ),
{ 35: } ( len: 2; sym: -28 ),
{ 36: } ( len: 2; sym: -28 ),
{ 37: } ( len: 2; sym: -33 ),
{ 38: } ( len: 2; sym: -33 ),
{ 39: } ( len: 0; sym: -34 ),
{ 40: } ( len: 3; sym: -33 ),
{ 41: } ( len: 0; sym: -36 ),
{ 42: } ( len: 4; sym: -33 ),
{ 43: } ( len: 0; sym: -38 ),
{ 44: } ( len: 3; sym: -33 ),
{ 45: } ( len: 0; sym: -39 ),
{ 46: } ( len: 4; sym: -33 ),
{ 47: } ( len: 0; sym: -40 ),
{ 48: } ( len: 4; sym: -33 ),
{ 49: } ( len: 0; sym: -41 ),
{ 50: } ( len: 4; sym: -33 ),
{ 51: } ( len: 3; sym: -33 ),
{ 52: } ( len: 2; sym: -33 ),
{ 53: } ( len: 0; sym: -35 ),
{ 54: } ( len: 3; sym: -35 ),
{ 55: } ( len: 1; sym: -37 ),
{ 56: } ( len: 2; sym: -37 ),
{ 57: } ( len: 3; sym: -37 ),
{ 58: } ( len: 1; sym: -37 ),
{ 59: } ( len: 2; sym: -37 ),
{ 60: } ( len: 3; sym: -37 ),
{ 61: } ( len: 1; sym: -43 ),
{ 62: } ( len: 1; sym: -43 ),
{ 63: } ( len: 1; sym: -43 ),
{ 64: } ( len: 2; sym: -43 ),
{ 65: } ( len: 2; sym: -43 ),
{ 66: } ( len: 1; sym: -42 ),
{ 67: } ( len: 2; sym: -42 ),
{ 68: } ( len: 3; sym: -42 ),
{ 69: } ( len: 1; sym: -42 ),
{ 70: } ( len: 2; sym: -42 ),
{ 71: } ( len: 3; sym: -42 ),
{ 72: } ( len: 1; sym: -44 ),
{ 73: } ( len: 0; sym: -46 ),
{ 74: } ( len: 2; sym: -29 ),
{ 75: } ( len: 0; sym: -47 ),
{ 76: } ( len: 0; sym: -48 ),
{ 77: } ( len: 5; sym: -29 ),
{ 78: } ( len: 2; sym: -29 ),
{ 79: } ( len: 1; sym: -29 ),
{ 80: } ( len: 2; sym: -29 ),
{ 81: } ( len: 0; sym: -50 ),
{ 82: } ( len: 0; sym: -52 ),
{ 83: } ( len: 6; sym: -45 ),
{ 84: } ( len: 1; sym: -49 ),
{ 85: } ( len: 0; sym: -54 ),
{ 86: } ( len: 4; sym: -49 ),
{ 87: } ( len: 0; sym: -51 ),
{ 88: } ( len: 2; sym: -51 ),
{ 89: } ( len: 2; sym: -51 ),
{ 90: } ( len: 2; sym: -51 ),
{ 91: } ( len: 2; sym: -51 ),
{ 92: } ( len: 2; sym: -51 ),
{ 93: } ( len: 0; sym: -56 ),
{ 94: } ( len: 3; sym: -55 ),
{ 95: } ( len: 1; sym: -55 ),
{ 96: } ( len: 0; sym: -53 ),
{ 97: } ( len: 0; sym: -58 ),
{ 98: } ( len: 4; sym: -53 ),
{ 99: } ( len: 0; sym: -59 ),
{ 100: } ( len: 4; sym: -53 ),
{ 101: } ( len: 0; sym: -60 ),
{ 102: } ( len: 4; sym: -53 ),
{ 103: } ( len: 2; sym: -53 ),
{ 104: } ( len: 0; sym: -57 ),
{ 105: } ( len: 1; sym: -57 )
);

// source: yyparse.cod line# 118

const _error = 256; (* error token *)

function yyact(state, sym : Integer; var act : Integer) : Boolean;
  (* search action table *)
  var k : Integer;
  begin
    k := yyal[state];
    while (k<=yyah[state]) and (yya[k].sym<>sym) do inc(k);
    if k>yyah[state] then
      yyact := false
    else
      begin
        act := yya[k].act;
        yyact := true;
      end;
  end(*yyact*);

function yygoto(state, sym : Integer; var nstate : Integer) : Boolean;
  (* search goto table *)
  var k : Integer;
  begin
    k := yygl[state];
    while (k<=yygh[state]) and (yyg[k].sym<>sym) do inc(k);
    if k>yygh[state] then
      yygoto := false
    else
      begin
        nstate := yyg[k].act;
        yygoto := true;
      end;
  end(*yygoto*);

function yycharsym(i : Integer) : String;
begin
  if (i >= 1) and (i <= 255) then
    begin
      if i < 32 then
        begin
          if i = 9 then
            Result := #39'\t'#39
          else if i = 10 then
            Result := #39'\f'#39
          else if i = 13 then
            Result := #39'\n'#39
          else
            Result := #39'\0x' + IntToHex(i,2) + #39;
        end
      else
        Result := #39 + Char(i) + #39;
      Result := ' literal ' + Result;
    end
  else
    begin
      if i < -1 then
        Result := ' unknown'
      else if i = -1 then
        Result := ' token $accept'
      else if i = 0 then
        Result := ' token $eof'
      else if i = 256 then
        Result := ' token $error'
{$ifdef yyextradebug}
      else if i <= yymaxtoken then
        Result := ' token ' + yytokens[yychar].tokenname
      else
        Result := ' unknown token';
{$else}
      else
        Result := ' token';
{$endif}
    end;
  Result := Result + ' ' + IntToStr(yychar);
end;

label parse, next, error, errlab, shift, reduce, accept, abort;

begin(*yyparse*)

  (* initialize: *)

  yystate := 0; yychar := -1; yynerrs := 0; yyerrflag := 0; yysp := 0;

parse:

  (* push state and value: *)

  inc(yysp);
  if yysp>yymaxdepth then
    begin
      yyerror('yyparse stack overflow');
      goto abort;
    end;
  yys[yysp] := yystate; yyv[yysp] := yyval;

next:

  if (yyd[yystate]=0) and (yychar=-1) then
    (* get next symbol *)
    begin
      yychar := lexer.parse(); if yychar<0 then yychar := 0;
    end;

  {$IFDEF YYDEBUG}writeln('state ', yystate, yycharsym(yychar));{$ENDIF}

  (* determine parse action: *)

  yyn := yyd[yystate];
  if yyn<>0 then goto reduce; (* simple state *)

  (* no default action; search parse table *)

  if not yyact(yystate, yychar, yyn) then goto error
  else if yyn>0 then                      goto shift
  else if yyn<0 then                      goto reduce
  else                                    goto accept;

error:

  (* error; start error recovery: *)

  if yyerrflag=0 then yyerror('syntax error');

errlab:

  if yyerrflag=0 then inc(yynerrs);     (* new error *)

  if yyerrflag<=2 then                  (* incomplete recovery; try again *)
    begin
      yyerrflag := 3;
      (* uncover a state with shift action on error token *)
      while (yysp>0) and not ( yyact(yys[yysp], _error, yyn) and
                               (yyn>0) ) do
        begin
          {$IFDEF YYDEBUG}
            if yysp>1 then
              writeln('error recovery pops state ', yys[yysp], ', uncovers ',
                      yys[yysp-1])
            else
              writeln('error recovery fails ... abort');
          {$ENDIF}
          dec(yysp);
        end;
      if yysp=0 then goto abort; (* parser has fallen from stack; abort *)
      yystate := yyn;            (* simulate shift on error *)
      goto parse;
    end
  else                                  (* no shift yet; discard symbol *)
    begin
      {$IFDEF YYDEBUG}writeln('error recovery discards ' + yycharsym(yychar));{$ENDIF}
      if yychar=0 then goto abort; (* end of input; abort *)
      yychar := -1; goto next;     (* clear lookahead char and try again *)
    end;

shift:

  (* go to new state, clear lookahead character: *)

  yystate := yyn; yychar := -1; yyval := yylval;
  if yyerrflag>0 then dec(yyerrflag);

  goto parse;

reduce:

  (* execute action, pop rule from stack, and go to next state: *)

  {$IFDEF YYDEBUG}writeln('reduce ' + IntToStr(-yyn) {$IFDEF YYEXTRADEBUG} + ' rule ' + yyr[-yyn].symname {$ENDIF});{$ENDIF}

  yyflag := yyfnone; yyaction(-yyn);
  dec(yysp, yyr[-yyn].len);
  if yygoto(yys[yysp], yyr[-yyn].sym, yyn) then yystate := yyn;

  (* handle action calls to yyaccept, yyabort and yyerror: *)

  case yyflag of
    yyfaccept : goto accept;
    yyfabort  : goto abort;
    yyferror  : goto errlab;
  end;

  goto parse;

accept:

  Result := 0; exit;

abort:

  Result := 1; exit;

end(*yyparse*);


(* Lexical analyzer (implemented in Turbo Pascal for maximum efficiency): *)

function TLexer.parse() : integer;
  function end_of_input : boolean;
    begin
      end_of_input := (cno>length(line)) and eof(yyin)
    end(*end_of_input*);
  procedure scan;
    (* scan for nonempty character, skip comments *)
    procedure scan_comment;
      var p : integer;
      begin
        p := pos('*/', copy(line, cno, length(line)));
        if p>0 then
          cno := cno+succ(p)
        else
          begin
            while (p=0) and not eof(yyin) do
              begin
                readln(yyin, line);
                inc(lno);
                p := pos('*/', line)
              end;
            if p=0 then
              begin
                cno := succ(length(line));
                error(open_comment_at_eof);
              end
            else
              cno := succ(succ(p))
          end
      end(*scan_comment*);
    begin
      while not end_of_input do
        if cno<=length(line) then
          case line[cno] of
            ' ', tab : inc(cno);
            '/' :
              if (cno<length(line)) and (line[succ(cno)]='*') then
                begin
                  inc(cno, 2);
                  scan_comment
                end
              else
                exit
            else
              exit
          end
        else
          begin
            readln(yyin, line);
            inc(lno); cno := 1;
          end
    end(*scan*);
  function scan_ident : integer;
    (* scan an identifier *)
    var
      idstr : String;
    begin
      idstr := line[cno];
      inc(cno);
      while (cno<=length(line)) and (
            ('A'<=upCase(line[cno])) and (upCase(line[cno])<='Z') or
            ('0'<=line[cno]) and (line[cno]<='9') or
            (line[cno]='_') or
            (line[cno]='.') ) do
        begin
          idstr := idstr+line[cno];
          inc(cno)
        end;
      yylval := get_key(idstr);
      scan;
      if not end_of_input and (line[cno]=':') then
        scan_ident := C_ID
      else
        scan_ident := ID
    end(*scan_ident*);
  function scan_literal: integer;
    (* scan a literal, i.e. string *)
    var
      idstr : AnsiString;
      oct_val : Byte;
    begin
      idstr := line[cno];
      inc(cno);
      while (cno<=length(line)) and (line[cno]<>idstr[1]) do
        if line[cno]='\' then
          if cno<length(line) then
            begin
              inc(cno);
              case line[cno] of
                'n' :
                  begin
                    idstr := idstr+nl;
                    inc(cno)
                  end;
                'r' :
                  begin
                    idstr := idstr+cr;
                    inc(cno)
                  end;
                't' :
                  begin
                    idstr := idstr+tab;
                    inc(cno)
                  end;
                'b' :
                  begin
                    idstr := idstr+bs;
                    inc(cno)
                  end;
                'f' :
                  begin
                    idstr := idstr+ff;
                    inc(cno)
                  end;
                '0'..'7' :
                  begin
                    oct_val := ord(line[cno])-ord('0');
                    inc(cno);
                    while (cno<=length(line)) and
                          ('0'<=line[cno]) and
                          (line[cno]<='7') do
                      begin
                        oct_val := oct_val*8+ord(line[cno])-ord('0');
                        inc(cno)
                      end;
                    idstr := idstr+chr(oct_val)
                  end
                else
                  begin
                    idstr := idstr+line[cno];
                    inc(cno)
                  end
              end
            end
          else
            inc(cno)
        else
          begin
            idstr := idstr+line[cno];
            inc(cno)
          end;
      if cno>length(line) then
        error(missing_string_terminator)
      else
        inc(cno);
      if length(idstr)=2 then
        begin
          yylval := ord(idstr[2]);
          scan_literal := LITERAL;
        end
      else if length(idstr)>1 then
        begin
          yylval := get_key(''''+copy(idstr, 2, pred(length(idstr)))+'''');
          scan_literal := LITID;
        end
      else
        scan_literal := ILLEGAL;
    end(*scan_literal*);
  function scan_num : integer;
    (* scan an unsigned integer *)
    var
      numstr : String;
      code : integer;
    begin
      numstr := line[cno];
      inc(cno);
      while (cno<=length(line)) and
            ('0'<=line[cno]) and (line[cno]<='9') do
        begin
          numstr := numstr+line[cno];
          inc(cno)
        end;
      val(numstr, yylval, code);
      if code=0 then
        scan_num := NUMBER
      else
        scan_num := ILLEGAL;
    end(*scan_num*);
  function scan_keyword : integer;
    (* scan %xy *)
    function lookup(key : String; var tok : integer) : boolean;
      (* table of Yacc keywords (unstropped): *)
      const
        no_of_entries = 12;
        max_entry_length = 8;
        keys : array [1..no_of_entries] of AnsiString = (
          '0', '2', 'binary', 'left', 'nonassoc', 'prec', 'right',
          'start', 'term', 'token', 'type', 'union');
        toks : array [1..no_of_entries] of integer = (
          PTOKEN, PNONASSOC, PNONASSOC, PLEFT, PNONASSOC, PPREC, PRIGHT,
          PSTART, PTOKEN, PTOKEN, PTYPE, PUNION);
      var m, n, k : integer;
      begin
        (* binary search: *)
        m := 1; n := no_of_entries;
        lookup := true;
        while m<=n do
          begin
            k := m+(n-m) div 2;
            if key=keys[k] then
              begin
                tok := toks[k];
                exit
              end
            else if key>keys[k] then
              m := k+1
            else
              n := k-1
          end;
        lookup := false
      end(*lookup*);
    var
      keywstr : String;
      tok : integer;
    begin
      inc(cno);
      if cno<=length(line) then
        case line[cno] of
          '<' :
            begin
              scan_keyword := PLEFT;
              inc(cno)
            end;
          '>' :
            begin
              scan_keyword := PRIGHT;
              inc(cno)
            end;
          '=' :
            begin
              scan_keyword := PPREC;
              inc(cno)
            end;
          '%', '\' :
            begin
              scan_keyword := PP;
              inc(cno)
            end;
          '{' :
            begin
              scan_keyword := LCURL;
              inc(cno)
            end;
          '}' :
            begin
              scan_keyword := RCURL;
              inc(cno)
            end;
          'A'..'Z', 'a'..'z', '0'..'9' :
            begin
              keywstr := line[cno];
              inc(cno);
              while (cno<=length(line)) and (
                    ('A'<=upCase(line[cno])) and (upCase(line[cno])<='Z') or
                    ('0'<=line[cno]) and (line[cno]<='Z') ) do
                begin
                  keywstr := keywstr+line[cno];
                  inc(cno)
                end;
              if lookup(keywstr, tok) then
                scan_keyword := tok
              else
                scan_keyword := ILLEGAL
            end;
          else scan_keyword := ILLEGAL
        end
      else
        scan_keyword := ILLEGAL;
    end(*scan_keyword*);
  function scan_char : integer;
    (* scan any single character *)
    begin
      scan_char := ord(line[cno]);
      inc(cno)
    end(*scan_char*);
  var lno0, cno0 : integer;
  begin
    tokleng := 0;
    scan;
    lno0 := lno; cno0 := cno;
    if end_of_input then
      Result := 0
    else
      case line[cno] of
        'A'..'Z', 'a'..'z', '_' : Result := scan_ident;
        '''', '"' : Result := scan_literal;
        '0'..'9' : Result := scan_num;
        '%', '\' : Result := scan_keyword;
        '=' :
          if (cno<length(line)) and (line[succ(cno)]='{') then
            begin
              inc(cno);
              Result := scan_char
            end
          else
            Result := scan_char;
        else Result := scan_char;
      end;
    if lno=lno0 then
      tokleng := cno-cno0
  end(*yylex*);

(* Main program: *)

var
  i : Integer;
  lexer : TLexer;
  parser : TParser;
  readonlyflag : Boolean;
  Attrs : Integer;

procedure openCodFile();
begin
  (* search code template in /usr/share/dyacclex/ (on linux),
     then current directory, then on path where Lex
     was executed from: *)

  codfilepath := ExtractFilePath(ParamStr(0));

  {$IFDEF LINUX}
  codfilename := '/usr/share/dyacclex/yyparse.cod';
  Assign(yycod, codfilename);
  reset(yycod);

  if (IOResult = 0) then
    exit;
  {$ENDIF}

  codfilename := 'yyparse.cod';
  Assign(yycod, codfilename);
  reset(yycod);

  if (IOResult = 0) then
    exit;

  codfilename := codfilepath + 'yyparse.cod';
  Assign(yycod, codfilename);
  reset(yycod);

  if (IOResult = 0) then
    exit;

  fatal(cannot_open_file + 'yyparse.cod');
end;

begin
  readonlyflag := False;

  (* sign-on: *)

  writeln(sign_on);

  (* parse command line: *)

  if paramCount=0 then
    begin
      writeln;
      writeln(usage);
      writeln(options);
      halt(0);
    end;

  yfilename := '';
  pasfilename := '';

  for i := 1 to paramCount do
    if copy(paramStr(i), 1, 1)='-' then
      if UpperCase(paramStr(i))='-V' then
        verbose := true
      else if UpperCase(paramStr(i))='-R' then
        readonlyflag := true
      else if UpperCase(paramStr(i))='-D' then
        debug := true
      else
        begin
          writeln(invalid_option, paramStr(i));
          halt(1);
        end
    else if yfilename='' then
      yfilename := addExt(paramStr(i), 'y')
    else if pasfilename='' then
      pasfilename := addExt(paramStr(i), 'pas')
    else
      begin
        writeln(illegal_no_args);
        halt(1);
      end;

  if yfilename='' then
    begin
      writeln(illegal_no_args);
      halt(1);
    end;

  if pasfilename='' then pasfilename := root(yfilename)+'.pas';
  lstfilename := root(yfilename)+'.lst';

  (* open files: *)

{$WARN SYMBOL_PLATFORM OFF}
{$IFDEF MSWINDOWS}
  if readonlyflag then begin
    if FileExists(pasfilename) then begin
      Attrs := FileGetAttr(pasfilename);
      FileSetAttr(pasfilename, Attrs and not faReadOnly);
    end;
  end;
{$WARN SYMBOL_PLATFORM ON}
{$ENDIF}

  assign(yyin, yfilename);
  assign(yyout, pasfilename);
  assign(yylst, lstfilename);

  reset(yyin);    if ioresult<>0 then fatal(cannot_open_file+yfilename);
  rewrite(yyout); if ioresult<>0 then fatal(cannot_open_file+pasfilename);
  rewrite(yylst); if ioresult<>0 then fatal(cannot_open_file+lstfilename);

  openCodFile();

  (* parse source grammar: *)

  write('parse ... ');

  lno := 0; cno := 1; line := ''; yycodlno := 0;


  next_section;
  if debug then writeln(yyout, '{$DEFINE YYDEBUG}');
  if debug then writeln(yyout, '{$DEFINE YYEXTRADEBUG}');

  lexer := TLexer.Create();
  parser := TParser.Create();
  parser.lexer := lexer;

  if (parser.parse() = 0) then
    { done }
  else if parser.yychar=0 then
    error(unexpected_eof)
  else
    error(syntax_error);

  if errors=0 then writeln('DONE');

  (* close files: *)

  close(yyin); close(yyout); close(yylst); close(yycod);

{$WARN SYMBOL_PLATFORM OFF}
{$IFDEF MSWINDOWS}
  if readonlyflag then begin
    Attrs := FileGetAttr(pasfilename);
    FileSetAttr(pasfilename, Attrs or faReadOnly);
  end;
{$ENDIF}
{$WARN SYMBOL_PLATFORM ON}

  (* print statistics: *)

  if errors>0 then
    writeln( lno, ' lines, ',
             errors, ' errors found.' )
  else
    begin
      writeln( lno, ' lines, ',
               n_rules-1, '/', max_rules-1, ' rules, ',
               n_states, '/', max_states, ' s, ',
               n_items, '/', max_items, ' i, ',
               n_trans, '/', max_trans, ' t, ',
               n_redns, '/', max_redns, ' r.');
      if shift_reduce>0 then
        writeln(shift_reduce, ' shift/reduce conflicts.');
      if reduce_reduce>0 then
        writeln(reduce_reduce, ' reduce/reduce conflicts.');
      if never_reduced>0 then
        writeln(never_reduced, ' rules never reduced.');
    end;

  if warnings>0 then writeln(warnings, ' warnings.');

  (* terminate: *)

  if errors>0 then
    begin
      erase(yyout);
      if ioresult<>0 then ;
    end;

  if file_size(lstfilename)=0 then
    erase(yylst)
  else
    writeln('(see ', lstfilename, ' for more information)');

  halt(errors);

end(*Yacc*).