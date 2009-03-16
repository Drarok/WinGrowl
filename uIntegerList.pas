unit uIntegerList;

interface

Uses
  Classes;

Type
  TIntegerList = Class(TList)
  Protected
    Function Get(Index: Integer): Integer; Reintroduce;
    Procedure Put(Index: Integer; Item: Integer); Reintroduce;
  Public
    Function Add(Item: Integer): Integer;
    Property Items[Index: Integer]: Integer read Get write Put; default;
  End;

implementation

{ TIntegerList }

function TIntegerList.Add(Item: Integer): Integer;
begin
  Result := Inherited Add(Pointer(Item));
end;

function TIntegerList.Get(Index: Integer): Integer;
begin
  Result := Integer(Inherited Get(Index));
end;

procedure TIntegerList.Put(Index, Item: Integer);
begin
  inherited Put(Index, Pointer(Item));
end;

end.
