unit uGrowlTypes;

interface

Uses
  Classes,
  IdGlobal;

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
    FRawData : TBytes;
    FStream : TMemoryStream;
    FPacketHeader : TGrowlPacketHeader;
    FChecksum : Array[0..15] Of Char;

    // Common to both types of packet
    FAppNameLength : Word;
    FAppName : String;

    // Used to flip the endian-ness before use.
    Function GetAppNameLength() : Word;

    Procedure GetChecksum();
  Public
    Constructor Create(AData : TBytes); Reintroduce; Virtual;
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
    FDefaults : TList;
  public
    Constructor Create(AData : TBytes); Override;
    Destructor Destroy(); Override;
    Property AppNameLength : Word Read GetAppNameLength;
    Property NotificationCount : Byte Read FNotificationCount;
    Property DefaultCount : Byte Read FDefaultCount;
    Property AppName : String Read FAppName;
    Property Notifications : TStringList Read FNotifications;
    Property Defaults : TList Read FDefaults;
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
    Constructor Create(AData : TBytes); Override;
    Destructor Destroy(); Override;

    Property Flags : Word Read GetFlags;
    Property Notification : String Read FNotificationName;
    Property Title : String Read FTitle;
    Property Description : String Read FDescription;
  End; {TGrowlPacketNotificationBody}

implementation

Uses
  SysUtils,
  md5;

// Change endianness of a 16 bit integer.
Function SwapWord(b : Word) : Word;
Asm
  bswap eax
  shr eax,16
End;

{ TGrowlPacket }

constructor TGrowlPacket.Create(AData: TBytes);
begin
  Inherited Create();
  FRawData := AData;
  FStream := TMemoryStream.Create();
  FStream.Write(AData[0], Length(AData));
  FStream.Position := 0;

  FStream.Read(FPacketHeader, SizeOf(FPacketHeader));

  If (FPacketHeader.Version <> GROWL_PROTOCOL_VERSION) Then
    Raise Exception.CreateFmt('Invalid packet received (%d)', [FPacketHeader.Version]);
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

procedure TGrowlPacket.GetChecksum;
begin
  FStream.Read(FChecksum, SizeOf(FChecksum));
end;

function TGrowlPacket.GetRegistractionPacket: TGrowlRegistrationPacket;
begin
  Result := TGrowlRegistrationPacket.Create(FRawData);
end;

function TGrowlPacket.GetNotificationPacket: TGrowlNotificationPacket;
begin
  Result := TGrowlNotificationPacket.Create(FRawData);
end;

{ TGrowlRegistrationPacket }

constructor TGrowlRegistrationPacket.Create(AData : TBytes);
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

  FDefaults := TList.Create();
  For x := 0 To FDefaultCount - 1 Do
  Begin
    FStream.Read(sDefault, SizeOf(sDefault));
    FDefaults.Add(Pointer(sDefault));
  End;

  GetChecksum();
end;

destructor TGrowlRegistrationPacket.Destroy;
begin
  FNotifications.Free();
  FDefaults.Free();
  Inherited;
end;

{ TGrowlNotificationPacket }

constructor TGrowlNotificationPacket.Create(AData: TBytes);
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
