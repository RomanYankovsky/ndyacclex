unit frmTest;

interface

uses
  {$IFDEF FPC}
  Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, expr, StdCtrls;
  {$ELSE}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, expr, Vcl.StdCtrls;
  {$ENDIF}

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Edit1: TEdit;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    Parser: TExprParser;
    procedure WriteCB(Value: Real);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
var
  StrStream: TStringStream;
begin
  if Key = #13 then
  begin
    Key := #0;
    Memo1.Lines.Add('> ' + Edit1.Text);

    {$IFDEF FPC}
    StrStream := TStringStream.Create('');
    {$ELSE}
    StrStream := TStringStream.Create;
    {$ENDIF}
    try
      StrStream.WriteString(Edit1.Text);
      StrStream.Position := 0;
      try
        Parser.parse(StrStream, WriteCB);
      except
        on E: EExprParserException do
          Memo1.Lines.Add(E.Message);
      end;
      Edit1.Text := '';
    finally
      StrStream.Free;
    end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Parser.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Parser := TExprParser.Create;
end;

procedure TForm1.WriteCB(Value: Real);
begin
  Memo1.Lines.Add(Format('%2.2f',[Value]));
end;

end.
