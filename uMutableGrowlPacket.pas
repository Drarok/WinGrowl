unit uMutableGrowlPacket;

interface

Uses
  Classes,
  uGrowlTypes;

Type
  TMutableGrowlPacket = Class(TObject)
  Private
  Protected
    FProtocolVersion : Byte;
    FPacketType : Byte;

    FAppName : String;

    FPassword : String;

    Procedure SetAppName(const Value: String);
    Function GetPacketStream() : TStream; Virtual;
  Public
    Constructor Create(); Virtual;

    Property ProtocolVersion : Byte Read FProtocolVersion Write FProtocolVersion;
    Property PacketType : Byte Read FPacketType;
    Property AppName : String Read FAppName Write SetAppName;

    Property Password : String Read FPassword Write FPassword;

    Function GetPacket() : TStream;
  End;


implementation

Uses
  md5;

{ TMutableGrowlPacket }

constructor TMutableGrowlPacket.Create;
begin
  FProtocolVersion := GROWL_PROTOCOL_VERSION;
end;

procedure TMutableGrowlPacket.SetAppName(const Value: String);
begin
  FAppName := Value;
end;

function TMutableGrowlPacket.GetPacketStream: TStream;
begin
  Result := TMemoryStream.Create();
  Result.Write(FProtocolVersion, SizeOf(FProtocolVersion));
  Result.Write(FPacketType, SizeOf(FPacketType));
end;

function TMutableGrowlPacket.GetPacket: TStream;
Var
  s : AnsiString;
  Digest : MD5Digest;
begin
  // Get the internal packet stream.
  Result := GetPacketStream();

  // Rewind and grab the data into a string.
  Result.Position := 0;
  SetLength(s, Result.Size);
  Result.ReadBuffer(s[1], Result.Size);

  // Append the password to the string.
  s := s + FPassword;

  // Append the md5 digest to the stream.
  Digest := MD5String(s);
  Result.WriteBuffer(Digest, SizeOf(Digest));

  // Rewind the stream ready for the user.
  Result.Position := 0;
end;

end.
