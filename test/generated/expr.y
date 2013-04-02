%{
unit expr;

interface

uses
	SysUtils,
	Classes,
	yacclib,
	lexlib,
        uStreamLexer;



%}

%token <Real> NUM       /* constants */
%token <Integer> ID     /* variables */
%type <Real> expr	/* expressions */

%left '+' '-'      	/* operators */
%left '*' '/'
%right UMINUS

%token ILLEGAL 		/* illegal token */

%%

input	: /* empty */
	| input '\n'		 { yyaccept; }
	| input expr '\n'	 { writecallback($2); }
	| input ID '=' expr '\n' { x[$2] := $4; writecallback($4); }
	| error '\n'             { yyerrok; }
	;

expr    :  expr '+' expr	 { $$ := $1 + $3; }
	|  expr '-' expr	 { $$ := $1 - $3; }
	|  expr '*' expr	 { $$ := $1 * $3; }
	|  expr '/' expr	 { $$ := $1 / $3; }
	|  '(' expr ')'		 { $$ := $2; }
	|  '-' expr              { $$ := -$2; }
           %prec UMINUS
	|  NUM                   { $$ := $1; }
        |  ID                    { $$ := x[$1]; }
	;

%%

{$I exprlex.pas}

end.