L				[A-Za-z]
D				[0-9]

%start

%%

  var result : integer;

{D}+(\.{D}+)?([Ee][+-]?{D}+)?	begin
				  val(yytext, yylval.yyReal, result);
				  if result=0 then
				    return(NUM)
				  else
				    return(ILLEGAL)
				end;

{L}				begin
				  yylval.yyInteger := ord(upCase(yytext[1]))-
				                      ord('A')+1;
				  return(ID)
				end;

" "             		;

.				|
\n				returnc(yytext[1]);
