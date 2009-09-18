unit uLibWinGrowlMain;

interface

Uses
  Classes,
  md5,
  uGrowlTypes,
  uMutableGrowlRegistrationPacket,
  uMutableGrowlNotificationPacket;

  Function GetRegistrationPacket() : TMutableGrowlRegistrationPacket;
  Function GetNotificationPacket() : TMutableGrowlNotificationPacket;

implementation

Function GetRegistrationPacket() : TMutableGrowlRegistrationPacket;
Begin
  Result := TMutableGrowlRegistrationPacket.Create();
  Result.AppName := 'PHP Notifier';
  Result.Notifications.Add('Informational');
  Result.Defaults.Add(Result.Notifications.Add('Warning'));
  Result.Password := 'password';
End;

Function GetNotificationPacket() : TMutableGrowlNotificationPacket;
Begin
  Result := TMutableGrowlNotificationPacket.Create();
  Result.AppName := 'PHP Notifier';
  Result.Notification := 'Warning';
  Result.Title := 'Apache';
  Result.Description := 'Something went wrong';
  Result.Password := 'password';
End;

end.
