unit uMutableGrowlNotificationPacket;

interface

Uses
  Classes,
  uGrowlTypes,
  uMutableGrowlPacket;

Type
  TMutableGrowlNotificationPacket = Class(TMutableGrowlPacket)
  Private
  Protected
    FNotification : String;
    FTitle : String;
    FDescription : String;
    
    Function GetPacketStream() : TStream; Override;
  Public
    Constructor Create(); Override;
    
    Property Notification : String Read FNotification Write FNotification;
    Property Title : String Read FTitle Write FTitle;
    Property Description : String Read FDescription Write FDescription;
  End;

implementation

{ TMutableGrowlNotificationPacket }

constructor TMutableGrowlNotificationPacket.Create;
begin
  Inherited;
  FPacketType := GROWL_TYPE_NOTIFICATION;
end;

function TMutableGrowlNotificationPacket.GetPacketStream: TStream;
Var
  WordBuffer : Word;
begin
  Result := Inherited GetPacketStream();

  // Flags aren't yet supported.
  WordBuffer := 0;
  Result.Write(WordBuffer, SizeOf(WordBuffer));

  // Notification Length.
  WordBuffer := SwapWord(Word(Length(Notification)));
  Result.Write(WordBuffer, SizeOf(WordBuffer));

  // Title Length.
  WordBuffer := SwapWord(Word(Length(Title)));
  Result.Write(WordBuffer, SizeOf(WordBuffer));

  // Description Length.
  WordBuffer := SwapWord(Word(Length(Description)));
  Result.Write(WordBuffer, SizeOf(WordBuffer));

  // App Name Length.
  WordBuffer := SwapWord(Word(Length(AppName)));
  Result.Write(WordBuffer, SizeOf(WordBuffer));

  // Notification String.
  Result.Write(Notification[1], Length(Notification));

  // Title String.
  Result.Write(Title[1], Length(Title));

  // Description String.
  Result.Write(Description[1], Length(Description));

  // App Name String.
  Result.Write(AppName[1], Length(AppName));
end;

end.
