unit uGrowlTypes;

interface

Uses
  Classes,
  IdGlobal,
  uIntegerList;

Const
  GROWL_PROTOCOL_VERSION = 1;

  GROWL_TYPE_REGISTRATION = 0;
  GROWL_TYPE_NOTIFICATION = 1;

Type
  // Forward declarations.
  TGrowlPacket = Class;
  TGrowlRegistrationPacket = Class;
  TGrowlNotificationPacket = Class;

  TGrowlPacketHeader = Record
    Version : Byte;
    PacketType : Byte;
  End; {TGrowlPacketHeader}

  TGrowlPacket = Class(TObject)
  Private
  Protected
    // Base declarations.
    FPassword : String;
    FRawData : TBytes;
    FStream : TMemoryStream;
    FPacketHeader : TGrowlPacketHeader;

    // Common to both types of packet
    FAppNameLength : Word;
    FAppName : String;

    // Used to flip the endian-ness before use.
    Function GetAppNameLength() : Word;

    Function CompareChecksums(Password : String) : Boolean;
  Public
    Constructor Create(AData : TBytes; Password : String); Reintroduce; Virtual;
    Destructor Destroy(); Override;

    Property Header : TGrowlPacketHeader Read FPacketHeader;

    Function GetRegistractionPacket() : TGrowlRegistrationPacket;
    Function GetNotificationPacket() : TGrowlNotificationPacket;
  End;

  TGrowlRegistrationPacket = Class(TGrowlPacket)
  private
  protected
    FNotificationCount : Byte;
    FDefaultCount : Byte;
    FNotifications : TStringList;
    FDefaults : TIntegerList;
  public
    Constructor Create(AData : TBytes; Password : String); Override;
    Destructor Destroy(); Override;
    Property AppNameLength : Word Read GetAppNameLength;
    Property NotificationCount : Byte Read FNotificationCount;
    Property DefaultCount : Byte Read FDefaultCount;
    Property AppName : String Read FAppName;
    Property Notifications : TStringList Read FNotifications;
    Property Defaults : TIntegerList Read FDefaults;
  End; {TGrowlRegistrationPacket}

  TGrowlNotificationPacket = Class(TGrowlPacket)
  private
  protected
    FFlags : Word;
    FNotificationLength : Word;
    FTitleLength : Word;
    FDescriptionLength : Word;
    FAppNameLength : Word;
    FNotificationName : String;
    FTitle : String;
    FDescription : String;

    Function GetFlags() : Word;
    Function GetNotificationLength() : Word;
    Function GetTitleLength() : Word;
    Function GetDescriptionLength() : Word;
  public
    Constructor Create(AData : TBytes; Password : String); Override;
    Destructor Destroy(); Override;

    Property Flags : Word Read GetFlags;
    Property Notification : String Read FNotificationName;
    Property Title : String Read FTitle;
    Property Description : String Read FDescription;
  End; {TGrowlPacketNotificationBody}

implementation

Uses
  SysUtils,
  Windows,
  md5;

// Change endianness of a 16 bit integer.
Function SwapWord(b : Word) : Word;
Asm
  bswap eax
  shr eax,16
End;

{ TGrowlPacket }

constructor TGrowlPacket.Create(AData: TBytes; Password : String);
begin
  Inherited Create();
  FPassword := Password;
  
  FRawData := AData;
  FStream := TMemoryStream.Create();
  FStream.Write(AData[0], Length(AData));
  FStream.Position := 0;

  FStream.Read(FPacketHeader, SizeOf(FPacketHeader));

  If (FPacketHeader.Version <> GROWL_PROTOCOL_VERSION) Then
    Raise Exception.CreateFmt('Invalid packet received (%d)', [FPacketHeader.Version]);

  If (Not CompareChecksums(FPassword)) Then
    Raise Exception.Create('Invalid password in packet');
end;

destructor TGrowlPacket.Destroy;
begin
  FStream.Free();
  inherited;
end;

function TGrowlPacket.GetAppNameLength: Word;
begin
  Result := SwapWord(FAppNameLength);
end;

function TGrowlPacket.GetRegistractionPacket: TGrowlRegistrationPacket;
begin
  Result := TGrowlRegistrationPacket.Create(FRawData, FPassword);
end;

function TGrowlPacket.GetNotificationPacket: TGrowlNotificationPacket;
begin
  Result := TGrowlNotificationPacket.Create(FRawData, FPassword);
end;

function TGrowlPacket.CompareChecksums(Password : String): Boolean;
Var
  Checksum,
  Final : MD5Digest;
  s : String;
begin
  s := BytesToString(FRawData, 0, Length(FRawData) - 16);
  s := s + Password;
  Final := MD5String(s);

  CopyMemory(@Checksum[0], @FRawData[Length(FRawData) - 16], 16);

  Result := MD5Match(Checksum, Final);
end;

{ TGrowlRegistrationPacket }

constructor TGrowlRegistrationPacket.Create(AData : TBytes; Password : String);
Var
  x : Integer;
  nLength : Word;
  sName : String;
  sDefault : Byte;
begin
  inherited;
  FStream.Read(FAppNameLength, SizeOf(FAppNameLength));

  FStream.Read(FNotificationCount, SizeOf(FNotificationCount));
  FStream.Read(FDefaultCount, SizeOf(FDefaultCount));

  SetLength(FAppName, AppNameLength);
  FStream.Read(FAppName[1], AppNameLength);

  FNotifications := TStringList.Create();
  For x := 0 To FNotificationCount - 1 Do
  Begin
    FStream.Read(nLength, SizeOf(nLength));
    nLength := SwapWord(nLength);
    SetLength(sName, nLength);
    FStream.Read(sName[1], nLength);
    FNotifications.Add(sName);
  End;

  FDefaults := TIntegerList.Create();
  For x := 0 To FDefaultCount - 1 Do
  Begin
    FStream.Read(sDefault, SizeOf(sDefault));
    FDefaults.Add(sDefault);
  End;
end;

destructor TGrowlRegistrationPacket.Destroy;
begin
  FNotifications.Free();
  FDefaults.Free();
  Inherited;
end;

{ TGrowlNotificationPacket }

constructor TGrowlNotificationPacket.Create(AData: TBytes; Password : String);
begin
  inherited;
  FStream.Read(FFlags, SizeOf(FFlags));
  FStream.Read(FNotificationLength, SizeOf(FNotificationLength));
  FStream.Read(FTitleLength, SizeOf(FTitleLength));
  FStream.Read(FDescriptionLength, SizeOf(FDescriptionLength));
  FStream.Read(FAppNameLength, SizeOf(FAppNameLength));

  SetLength(FNotificationName, GetNotificationLength());
  FStream.Read(FNotificationName[1], GetNotificationLength());

  SetLength(FTitle, GetTitleLength());
  FStream.Read(FTitle[1], GetTitleLength());

  SetLength(FDescription, GetDescriptionLength());
  FStream.Read(FDescription[1], GetDescriptionLength());

  SetLength(FAppName, GetAppNameLength());
  FStream.Read(FAppName[1], GetAppNameLength());
end;

destructor TGrowlNotificationPacket.Destroy;
begin
  Inherited;
end;

function TGrowlNotificationPacket.GetDescriptionLength: Word;
begin
  Result := SwapWord(FDescriptionLength);
end;

function TGrowlNotificationPacket.GetFlags: Word;
begin
  Result := SwapWord(FFlags);
end;

function TGrowlNotificationPacket.GetNotificationLength: Word;
begin
  Result := SwapWord(FNotificationLength);
end;

function TGrowlNotificationPacket.GetTitleLength: Word;
begin
  Result := SwapWord(FTitleLength);
end;

end.
