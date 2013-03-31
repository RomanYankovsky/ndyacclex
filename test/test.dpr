program test;

uses
  Vcl.Forms,
  frmTest in 'frmTest.pas' {Form1},
  expr in 'generated\expr.pas',
  uStreamLexer in 'uStreamLexer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
