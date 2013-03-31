unit uStreamLexer;

interface

uses
  Classes, lexlib;

type
  TStreamLexer = class(TCustomLexer)
  private
    bufptr: integer;
    buf: array [1 .. max_chars] of AnsiChar;
    yyinput, yyoutput: TStream; // input and output file
  protected
    function get_char: AnsiChar; override;
    procedure unget_char(c: AnsiChar); override;
    procedure put_char(c: AnsiChar); override;
    procedure yyclear; override;
  public
    constructor Create(AStreamIn, StreamOut: TStream); reintroduce;
  end;

implementation

{ TStreamLexer }

constructor TStreamLexer.Create(AStreamIn, StreamOut: TStream);
begin
  inherited Create;
  yyinput := AStreamIn;
  yyoutput := StreamOut;
end;

function TStreamLexer.get_char: AnsiChar;
var
  i: integer;

  function ReadLnFromStream: AnsiString;
  var
    CurChar: AnsiChar;
  begin
    Result := '';
    repeat
      yyinput.Read(CurChar, SizeOf(CurChar));
      Result := Result + CurChar;
    until (yyinput.Position >= yyinput.Size) or (CurChar = nl);
  end;

begin
  if (bufptr = 0) and (yyinput.Position < yyinput.Size) then
  begin
    yyline := ReadLnFromStream;

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

procedure TStreamLexer.put_char(c: AnsiChar);
begin
  if c = #0 then
    { ignore }
  else {if c = nl then
    writeln(yyoutput)
  else}
    yyoutput.Write(c, SizeOf(c))
end;

procedure TStreamLexer.unget_char(c: AnsiChar);
begin
{  if bufptr = max_chars then
    fatal('input buffer overflow');}
  Inc(bufptr);
  Dec(yycolno);
  buf[bufptr] := c;
end;

procedure TStreamLexer.yyclear;
begin
  inherited;
  bufptr := 0;
end;

end.
