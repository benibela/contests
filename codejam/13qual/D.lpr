program D;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this };

type TKeySet = array[1..400] of integer;

var
  fin, fout: textfile;
  KK, N: integer;
  keysSet: array[1..400] of integer;
  chestLock: array[1..200] of integer;
  chestKeys: array[1..200,0..400] of integer;
  opened: array[1..200] of boolean;
  maxK: integer = 0;
  tmaxK: integer = 0;

procedure applyKeys(chest: integer; var keys: TKeySet);
var
  i: Integer;
begin
  keys[chestLock[chest]] -= 1;
  for i := 1 to chestKeys[chest, 0] do keys[chestKeys[chest, i]] += 1;
end;

type TOO = array[1..200] of boolean;
function issolvable(chest: integer = -1): boolean;
var oks: array[1..400] of integer; //override key set
    usedkeys: array[1..400] of boolean;
    oo: TOO; //override opened
    changed: boolean;
    i: Integer;
    neededKeys: array[1..400] of integer;
    existingKeys: array[1..400] of integer;
    j: Integer;
begin
  oo := opened;
  oks := keysSet;
  FillChar(usedkeys, sizeof(usedkeys), 0);
  if chest > -1 then begin
    oo[chest] := true;
    applyKeys(chest, oks);
  end;


  FillChar(neededKeys, sizeof(neededKeys), 0);
  existingKeys := oks;
  for i := 1 to N do
    if not oo[i] then begin
      neededKeys[chestLock[i]] += 1;
      for j := 1 to chestKeys[i,0] do
        existingKeys[chestKeys[i,j]]+=1;
    end;
  for i := 1 to 400 do
    if neededKeys[i] > existingKeys[i] then exit(false);

  changed := true;
  while changed do begin
    changed:=false;
    for i := 1 to maxK do
      if (oks[i] > 0) and not usedkeys[i] then begin
        usedkeys[i] := true;
        for j := 1 to N do
          if (chestLock[j] = i) and not oo[j] then begin
            applyKeys(j, oks);
            oo[j] := true;
            changed := true;
          end;
      end;
  end;

  for i := 1 to n do if not oo[i] then exit(false);

  exit(true);

end;

procedure handle;
var
  i, j, k: Integer;
begin
  readln(fin, KK, N);
  fillchar(keysSet, sizeof(keysSet), 0);
  maxK := 0;
  for i := 1 to Kk do begin
    read(fin, k);
    keysSet[k] += 1;
    if k >= maxK then maxK := k;
  end;
  for i := 1 to n do begin
    read(fin, chestLock[i], chestKeys[i,0]);
    if chestLock[i] > maxK then maxK := chestLock[i];
    for j := 1 to chestKeys[i,0] do begin
      read(fin, chestKeys[i,j]);
      if chestKeys[i,j] > maxK then maxK := chestKeys[i,j];
    end;
  end;
  if tmaxK < maxK then tmaxK := maxK;
  FillChar(opened, sizeof(opened), 0);
  if not issolvable then begin write(fout, ' IMPOSSIBLE'); exit; end;
  for i := 1 to n do begin
    for j := 1 to n do begin
      if not opened[j] and (keysSet[chestLock[j]] > 0) and issolvable(j) then begin
        write(fout, ' ',j);
        opened[j] := true;
        applyKeys(j, keysSet);
        break;
      end;
    end;
  end;
end;

var t: integer;
  tt: Integer;
  fn: String;
begin
  fn :=  'D-small-attempt1';
 // fn := 'D-example';
  fn := 'D-large';
  AssignFile(fin, '/tmp/'+fn+'.in');
  AssignFile(fout, '/tmp/'+fn+'.out');
  Reset(fin);
  Rewrite(fout);
  readln(fin, t);
  for tt := 1 to t do begin
    write(fout, 'Case #', tt, ':');
    handle;
    writeln(fout);
  end;
  CloseFile(fin);
  CloseFile(fout);
  writeln(tmaxK);
end.

