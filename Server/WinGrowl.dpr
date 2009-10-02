program WinGrowl;

uses
  Forms,
  md5 in '..\Shared\md5.pas',
  uMain in 'uMain.pas' {frmMain},
  uGrowlTypes in '..\Shared\uGrowlTypes.pas',
  uIntegerList in '..\Shared\uIntegerList.pas',
  ufrmNotification in 'ufrmNotification.pas' {frmNotification},
  uNotificationList in 'uNotificationList.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := 'WinGrowl';
  Application.CreateForm(TfrmMain, frmMain);
  Application.OnMinimize := frmMain.OnMinimize;
  Application.Run;
end.
