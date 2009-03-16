program WinGrowl;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uGrowlTypes in 'uGrowlTypes.pas',
  md5 in 'md5.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
