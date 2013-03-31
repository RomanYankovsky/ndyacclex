


function TExprLexer.parse() : integer;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)

  var result : integer;

begin
  (* actions: *)
  case yyruleno of
  1:
                             	begin
				  val(yytext, yylval.yyReal, result);
				  if result=0 then
				    return(NUM)
				  else
				    return(ILLEGAL)
				end;

  2:
   				begin
				  yylval.yyInteger := ord(upCase(yytext[1]))-
				                      ord('A')+1;
				  return(ID)
				end;

  3:
                		;

  4,
  5:
  				returnc(yytext[1]);
  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 11;
yynmatches = 11;
yyntrans   = 23;
yynstates  = 13;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  1,
  4,
  { 3: }
  2,
  4,
  { 4: }
  3,
  4,
  { 5: }
  4,
  { 6: }
  5,
  { 7: }
  1,
  { 8: }
  { 9: }
  { 10: }
  1,
  { 11: }
  { 12: }
  1
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
  1,
  4,
{ 3: }
  2,
  4,
{ 4: }
  3,
  4,
{ 5: }
  4,
{ 6: }
  5,
{ 7: }
  1,
{ 8: }
{ 9: }
{ 10: }
  1,
{ 11: }
{ 12: }
  1
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#9,#11..#31,'!'..'/',':'..'@','['..'`',
            '{'..#255 ]; s: 5),
  ( cc: [ #10 ]; s: 6),
  ( cc: [ ' ' ]; s: 4),
  ( cc: [ '0'..'9' ]; s: 2),
  ( cc: [ 'A'..'Z','a'..'z' ]; s: 3),
{ 1: }
  ( cc: [ #1..#9,#11..#31,'!'..'/',':'..'@','['..'`',
            '{'..#255 ]; s: 5),
  ( cc: [ #10 ]; s: 6),
  ( cc: [ ' ' ]; s: 4),
  ( cc: [ '0'..'9' ]; s: 2),
  ( cc: [ 'A'..'Z','a'..'z' ]; s: 3),
{ 2: }
  ( cc: [ '.' ]; s: 8),
  ( cc: [ '0'..'9' ]; s: 7),
  ( cc: [ 'E','e' ]; s: 9),
{ 3: }
{ 4: }
{ 5: }
{ 6: }
{ 7: }
  ( cc: [ '.' ]; s: 8),
  ( cc: [ '0'..'9' ]; s: 7),
  ( cc: [ 'E','e' ]; s: 9),
{ 8: }
  ( cc: [ '0'..'9' ]; s: 10),
{ 9: }
  ( cc: [ '+','-' ]; s: 11),
  ( cc: [ '0'..'9' ]; s: 12),
{ 10: }
  ( cc: [ '0'..'9' ]; s: 10),
  ( cc: [ 'E','e' ]; s: 9),
{ 11: }
  ( cc: [ '0'..'9' ]; s: 12),
{ 12: }
  ( cc: [ '0'..'9' ]; s: 12)
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 5,
{ 5: } 7,
{ 6: } 8,
{ 7: } 9,
{ 8: } 10,
{ 9: } 10,
{ 10: } 10,
{ 11: } 11,
{ 12: } 11
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 4,
{ 4: } 6,
{ 5: } 7,
{ 6: } 8,
{ 7: } 9,
{ 8: } 9,
{ 9: } 9,
{ 10: } 10,
{ 11: } 10,
{ 12: } 11
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 5,
{ 5: } 7,
{ 6: } 8,
{ 7: } 9,
{ 8: } 10,
{ 9: } 10,
{ 10: } 10,
{ 11: } 11,
{ 12: } 11
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 4,
{ 4: } 6,
{ 5: } 7,
{ 6: } 8,
{ 7: } 9,
{ 8: } 9,
{ 9: } 9,
{ 10: } 10,
{ 11: } 10,
{ 12: } 11
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 6,
{ 2: } 11,
{ 3: } 14,
{ 4: } 14,
{ 5: } 14,
{ 6: } 14,
{ 7: } 14,
{ 8: } 17,
{ 9: } 18,
{ 10: } 20,
{ 11: } 22,
{ 12: } 23
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 5,
{ 1: } 10,
{ 2: } 13,
{ 3: } 13,
{ 4: } 13,
{ 5: } 13,
{ 6: } 13,
{ 7: } 16,
{ 8: } 17,
{ 9: } 19,
{ 10: } 21,
{ 11: } 22,
{ 12: } 23
);


var yyn : Integer;

label start, scan, action;

begin

start:

  (* initialize: *)

  yynew;

scan:

  (* mark positions and matches: *)

  for yyn := yykl[yystate] to     yykh[yystate] do yymark(yyk[yyn]);
  for yyn := yymh[yystate] downto yyml[yystate] do yymatch(yym[yyn]);

  if yytl[yystate]>yyth[yystate] then goto action; (* dead state *)

  (* get next character: *)

  yyscan;

  (* determine action: *)

  yyn := yytl[yystate];
  while (yyn<=yyth[yystate]) and not (yyactchar in yyt[yyn].cc) do inc(yyn);
  if yyn>yyth[yystate] then goto action;
    (* no transition on yyactchar in this state *)

  (* switch to new state: *)

  yystate := yyt[yyn].s;

  goto scan;

action:

  (* execute action: *)

  if yyfind(yyrule) then
    begin
      yyaction(yyrule);
      if yyreject then goto action;
    end
  else if not yydefault and yywrap then
    begin
      yyclear;
      return(0);
    end;

  if not yydone then goto start;

  Result := yyretval;

end(*yylex*);

