program WinGrowl;

uses
  ShareMem,
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uGrowlTypes in 'uGrowlTypes.pas',
  md5 in 'md5.pas',
  uIntegerList in 'uIntegerList.pas',
  ufrmNotification in 'ufrmNotification.pas' {frmNotification},
  uNotificationList in 'uNotificationList.pas',
  uLibWinGrowlMain in 'uLibWinGrowlMain.pas',
  uMutableGrowlNotificationPacket in 'uMutableGrowlNotificationPacket.pas',
  uMutableGrowlRegistrationPacket in 'uMutableGrowlRegistrationPacket.pas',
  uMutableGrowlPacket in 'uMutableGrowlPacket.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
