unit uLibWinGrowlMain;

interface

Uses
  Classes,
  IdUDPClient,
  uMutableGrowlRegistrationPacket;

  Function CreateRegistrationPacket() : Pointer;
  Procedure FreeRegistrationPacket(Packet : Pointer);
  Procedure Registration_SetAppName(Packet : Pointer; Name : PChar);
  Procedure Registration_AddNotification(Packet : Pointer; Name : PChar; Default : Boolean);
  Procedure Registration_SetPassword(Packet : Pointer; Password : PChar);
  Procedure Registration_SendPacket(Packet : Pointer; Host : PChar; Port : Integer);

implementation

Uses
  SysUtils;

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

Procedure Registration_SendPacket(Packet : Pointer; Host : PChar; Port : Integer);
Var
  UDPClient :  TIdUDPClient;
  Stream : TStream;
  s : String;
Begin
  UDPClient := TIdUDPClient.Create(Nil);
  UDPClient.Host := Host;
  UDPClient.Port := Port;

  Stream := TMutableGrowlRegistrationPacket(Packet).GetPacket();
  SetLength(s, Stream.Size);
  Stream.Read(s[1], Stream.Size);

  UDPClient.Send(s);

  UDPClient.Free();
End;

end.
