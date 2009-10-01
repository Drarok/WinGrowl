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

  CreateNotificationPacket,
  FreeNotificationPacket,
  Notification_SetAppName,
  Notification_SetNotification,
  Notification_SetTitle,
  Notification_SetDescription,
  Notification_SetPassword,

  SendPacket;
begin

end.

