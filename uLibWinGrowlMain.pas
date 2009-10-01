unit uLibWinGrowlMain;

interface

Uses
  Classes,
  IdUDPClient,
  uMutableGrowlRegistrationPacket,
  uMutableGrowlNotificationPacket;

  Function CreateRegistrationPacket() : Pointer;
  Procedure FreeRegistrationPacket(Packet : Pointer);
  Procedure Registration_SetAppName(Packet : Pointer; Name : PChar);
  Procedure Registration_AddNotification(Packet : Pointer; Name : PChar; Default : Boolean);
  Procedure Registration_SetPassword(Packet : Pointer; Password : PChar);

  Function CreateNotificationPacket() : Pointer;
  Procedure FreeNotificationPacket(Packet : Pointer);
  Procedure Notification_SetAppName(Packet : Pointer; Name : PChar);
  Procedure Notification_SetNotification(Packet : Pointer; Notification : PChar);
  Procedure Notification_SetTitle(Packet : Pointer; Title : PChar);
  Procedure Notification_SetDescription(Packet : Pointer; Description : PChar);
  Procedure Notification_SetPassword(Packet : Pointer; Password : PChar);

  Procedure SendPacket(Packet : Pointer; Host : PChar; Port : Integer);

implementation

Uses
  SysUtils,
  uMutableGrowlPacket;

Function CreateRegistrationPacket() : Pointer;
Begin
  Result := TMutableGrowlRegistrationPacket.Create();
End;

Procedure FreeRegistrationPacket(Packet : Pointer);
Begin
  TMutableGrowlRegistrationPacket(Packet).Free();
End;

Procedure Registration_SetAppName(Packet : Pointer; Name : PChar);
Begin
  TMutableGrowlRegistrationPacket(Packet).AppName := String(Name);
End;

Procedure Registration_AddNotification(Packet : Pointer; Name : PChar; Default : Boolean);
Var
  i : Integer;
Begin
  i := TMutableGrowlRegistrationPacket(Packet).Notifications.Add(String(Name));
  If (Default) Then
    TMutableGrowlRegistrationPacket(Packet).Defaults.Add(i);
End;

Procedure Registration_SetPassword(Packet : Pointer; Password : PChar);
Begin
  TMutableGrowlRegistrationPacket(Packet).Password := String(Password);
End;

Function CreateNotificationPacket() : Pointer;
Begin
  Result := TMutableGrowlNotificationPacket.Create();
End;

Procedure FreeNotificationPacket(Packet : Pointer);
Begin
  TMutableGrowlNotificationPacket(Packet).Free
End;

Procedure Notification_SetAppName(Packet : Pointer; Name : PChar);
Begin
  TMutableGrowlNotificationPacket(Packet).AppName := String(Name);
End;

Procedure Notification_SetNotification(Packet : Pointer; Notification : PChar);
Begin
  TMutableGrowlNotificationPacket(Packet).Notification := String(Notification);
End;

Procedure Notification_SetTitle(Packet : Pointer; Title : PChar);
Begin
  TMutableGrowlNotificationPacket(Packet).Title := String(Title);
End;

Procedure Notification_SetDescription(Packet : Pointer; Description : PChar);
Begin
  TMutableGrowlNotificationPacket(Packet).Description := String(Description);
End;

Procedure Notification_SetPassword(Packet : Pointer; Password : PChar);
Begin
  TMutableGrowlNotificationPacket(Packet).Password := String(Password);
End;

Procedure SendPacket(Packet : Pointer; Host : PChar; Port : Integer);
Var
  UDPClient :  TIdUDPClient;
  Stream : TStream;
  s : String;
Begin
  UDPClient := TIdUDPClient.Create();
  UDPClient.Host := String(Host);
  UDPClient.Port := Port;

  Stream := TMutableGrowlPacket(Packet).GetPacket();
  SetLength(s, Stream.Size);
  Stream.Read(s[1], Stream.Size);

  UDPClient.Send(s);

  UDPClient.Free();
End;

end.
