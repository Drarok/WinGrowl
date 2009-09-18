library LibWinGrowl;

uses
  SysUtils,
  Classes,
  uGrowlTypes in 'uGrowlTypes.pas',
  uIntegerList in 'uIntegerList.pas',
  uLibWinGrowlMain in 'uLibWinGrowlMain.pas',
  uMutableGrowlNotificationPacket in 'uMutableGrowlNotificationPacket.pas',
  uMutableGrowlPacket in 'uMutableGrowlPacket.pas',
  uMutableGrowlRegistrationPacket in 'uMutableGrowlRegistrationPacket.pas';

{$R *.RES}

Exports
  CreateRegistrationPacket,
  FreeRegistrationPacket,
  Registration_SetAppName,
  Registration_AddNotification,
  Registration_SetPassword,
  Registration_SendPacket;

begin

end.

