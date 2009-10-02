unit uMutableGrowlRegistrationPacket;

interface

Uses
  Classes,
  uGrowlTypes,
  uMutableGrowlPacket,
  uIntegerList;

Type
  TMutableGrowlRegistrationPacket = Class(TMutableGrowlPacket)
  Private
  Protected
    FNotifications : TStringList;
    FDefaults : TIntegerList;

    Function GetPacketStream() : TStream; Override;
  Public
    Constructor Create(); Override;
    Destructor Destroy(); Override;

    Property Notifications : TStringList Read FNotifications;
    Property Defaults : TIntegerList Read FDefaults;
  End;

implementation

{ TMutableGrowlRegistrationPacket }

constructor TMutableGrowlRegistrationPacket.Create;
begin
  Inherited;

  FPacketType := GROWL_TYPE_REGISTRATION;

  FNotifications := TStringList.Create();
  FDefaults := TIntegerList.Create();
end;

destructor TMutableGrowlRegistrationPacket.Destroy;
begin
  FNotifications.Free();
  FDefaults.Free();
  inherited;
end;

function TMutableGrowlRegistrationPacket.GetPacketStream: TStream;
Var
  ByteBuffer : Byte;
  WordBuffer : Word;
  x : Integer;
  NotifLen : Word;
  NotifName : String;
begin
  Result := Inherited GetPacketStream();

  WordBuffer := SwapWord(Word(Length(FAppName)));
  Result.Write(WordBuffer, SizeOf(WordBuffer));

  ByteBuffer := FNotifications.Count;
  Result.Write(ByteBuffer, SizeOf(ByteBuffer));

  ByteBuffer := FDefaults.Count;
  Result.Write(ByteBuffer, SizeOf(ByteBuffer));

  Result.Write(FAppName[1], Length(FAppName));

  For x := 0 To FNotifications.Count - 1 Do
  Begin
    NotifName := FNotifications.Strings[x];
    NotifLen := SwapWord(Length(NotifName));
    Result.Write(NotifLen, SizeOf(NotifLen));
    Result.Write(NotifName[1], Length(NotifName));
  End;

  For x := 0 To FDefaults.Count - 1 Do
  Begin
    ByteBuffer := FDefaults.Items[x];
    Result.Write(ByteBuffer, SizeOf(ByteBuffer));
  End;
end;

end.
