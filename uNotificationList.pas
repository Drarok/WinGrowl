unit uNotificationList;

interface

Uses
  Classes,
  ufrmNotification;

Type
  TNotificationList = Class(TThreadList)
  private
    function GetCount: Integer;
  protected
    function Get(Index: Integer): TfrmNotification;
    procedure Put(Index: Integer; Item: TfrmNotification);
  public
    procedure Delete(Index : Integer);
    property Items[Index: Integer] : TfrmNotification read Get write Put; default;
    property Count : Integer read GetCount;
  End; {TNotificationList}

implementation

{ TNotificationList }

procedure TNotificationList.Delete(Index: Integer);
begin
  Try
    With LockList() Do
      Delete(Index);
  Finally
    UnlockList();
  End;
end;

function TNotificationList.Get(Index: Integer): TfrmNotification;
begin
  Try
    With LockList() Do
      Result := Items[Index];
  Finally
    UnlockList();
  End;
end;

function TNotificationList.GetCount: Integer;
begin
  Try
    With LockList() Do
      Result := Count;
  Finally
    Unlocklist();
  End;
end;

procedure TNotificationList.Put(Index: Integer; Item: TfrmNotification);
begin
  Try
    With LockList() Do
      Items[Index] := Item;
  Finally
    UnlockList();
  End;
end;

end.
