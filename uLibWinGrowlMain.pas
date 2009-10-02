unit uLibWinGrowlMain;

interface

Uses
  Classes,
  IdUDPClient,
  uMutableGrowlRegistrationPacket,
  uMutableGrowlNotificationPacket;

  Function CreateRegistrationPacket(AppName, Password : PChar) : Pointer;
  Procedure FreeRegistrationPacket(Packet : Pointer);
  Procedure Registration_AddNotification(Packet : Pointer; Name : PChar; Default : Boolean);

  Function CreateNotificationPacket(AppName, Notification, Title, Description, Password : PChar) : Pointer;
  Procedure FreeNotificationPacket(Packet : Pointer);

  Procedure SendPacket(Packet : Pointer; Host : PChar; Port : Integer);

implementation

Uses
  SysUtils,
  uMutableGrowlPacket;

Function CreateRegistrationPacket(AppName, Password : PChar) : Pointer;
Var
  p : TMutableGrowlRegistrationPacket;
Begin
  p := TMutableGrowlRegistrationPacket.Create();
  p.AppName := String(AppName);
  p.Password := String(Password);

  Result := p;
End;

Procedure FreeRegistrationPacket(Packet : Pointer);
Begin
  TMutableGrowlRegistrationPacket(Packet).Free();
End;

Procedure Registration_AddNotification(Packet : Pointer; Name : PChar; Default : Boolean);
Var
  i : Integer;
Begin
  i := TMutableGrowlRegistrationPacket(Packet).Notifications.Add(String(Name));
  If (Default) Then
    TMutableGrowlRegistrationPacket(Packet).Defaults.Add(i);
End;

Function CreateNotificationPacket(AppName, Notification, Title, Description, Password : PChar) : Pointer;
Var
  p : TMutableGrowlNotificationPacket;
Begin
  p := TMutableGrowlNotificationPacket.Create();
  p.AppName := String(AppName);
  p.Notification := String(Notification);
  p.Title := String(Title);
  p.Description := String(Description);
  p.Password := String(Password);
  
  Result := p;
End;

Procedure FreeNotificationPacket(Packet : Pointer);
Begin
  TMutableGrowlNotificationPacket(Packet).Free
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
