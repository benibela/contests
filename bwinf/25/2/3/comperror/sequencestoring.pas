unit sequenceStoring;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,calculation;

type
  TSequencePosition = record
    s: TSequence;
    i: longint;
  end;
  
  {PAVLTreeNode=^TAVLTreeNode;
  TAVLTreeNode=record
    n: intnumber; //Zahl
    b: longint;   //Balance
    p: array of TSequencePosition; //
    l,r: PAVLTreeNode;
  end;
                               }
  { TSequenceStore }

  TSequenceStore=class
  private
    seqs: TFPList;
    suffixs: array of TSequencePosition;
    function findMatch(values: array of intnumber ):longint;
    //numbers: PAVLTreeNode;
  public
    constructor create;
    destructor destroy;override;
    function add(seq: TSequence):boolean;
    //function findOne(values: array of intnumber): TSequence;
    procedure findAll(values: array of intnumber; resultList: TFPList);
  end;

implementation

{procedure insert(var node: PAVLTreeNode;n: intnumber; s: TSequence; i:longint);
begin
  if node=nil then begin
    new(node);
    FillChar(node^,sizeof(node^),0);
    node^.n:=n;
    setlength(node^.p,1);
    node^.p[0].s:=s;
    node^.p[0].i:=i;
  end else if node^.n=n then begin
    setlength(node^.p,length(node^.p)+1);
    node^.p[high(node^.p)].s:=s;
    node^.p[high(node^.p)].i:=i;
  end else if node^.n<n then Insert(node^.r,n,s,i)
  else Insert(node^.l,n,s,i);
end;

function find(node: PAVLTreeNode; n: intnumber):PAVLTreeNode;
begin
  if (node=nil) or (node^.n=n) then exit(node)
  else if node^.n<n then exit(find(node^.r,n))
  else exit(find(node^.l,n));
end;}

function cmpSequences(s1,s2:array of intnumber;i1,i2:longint): longint;
var i,minhigh:longint;
begin
  if high(s1)-i1>high(s2)-i2 then begin
    result:=-1;
    minhigh:=high(s2)-i2;
  end else if high(s1)-i1<high(s2)-i2 then begin
    result:=1;
    minhigh:=high(s1)-i1;
  end else begin
    result:=0;
    minhigh:=high(s2)-i2;
  end;
  for i:=0 to minhigh do
    if s1[i+i1]<>s2[i+i2] then
      if s1[i+i1]>s2[i+i2] then exit(-1)
      else exit(1);
end;

function cmpSeqPositions(const sp1,sp2:TSequencePosition): longint;inline;
begin
  result:=cmpSequences(sp1.s.values,sp2.s.values,sp1.i,sp2.i);
end;

{ TSequenceStore }

function TSequenceStore.findMatch(values: array of intnumber): longint;
var l,r,p:longint;
begin
  l:=0;
  r:=high(suffixs);
  while l<=r do begin
    p:=(l+r) div 2;
    case cmpSequences(values,suffixs[p].s.values,0,suffixs[p].i) of
      0: exit(p);
      -1: l:=p+1;
      1: r:=p-1;
    end;
  end;
  exit(-1);
end;

constructor TSequenceStore.create;
begin
  Seqs:=TFPList.Create;
end;

destructor TSequenceStore.destroy;
begin
  seqs.free;
  inherited;
end;

function TSequenceStore.add(seq: TSequence):boolean;
var i,j:longint;
    temp:TSequencePosition;
begin
  writeln('Add ',seqs.count);
  if findMatch(seq.values) > -1 then exit(false);
  seqs.add(seq);
  setlength(suffixs,length(suffixs)+length(seq.values));
  for i:=0 to high(seq.values) do begin
    suffixs[i+high(suffixs)-length(seq.values)].s:=seq;
    suffixs[i+high(suffixs)-length(seq.values)].i:=i;
  end;
  for i:=high(suffixs)-length(seq.values) to high(suffixs) do
    for j:=i-1 downto 0 do
      if cmpSeqPositions(suffixs[j],suffixs[j+1])=-1 then begin
        temp:=suffixs[j];
        suffixs[j]:=suffixs[j+1];
        suffixs[j+1]:=temp;
      end;
  result:=true;
{  for i:=0 to high(seq.values) do
    insert(numbers,seq.values[i],seq,i);}
end;

procedure TSequenceStore.findAll(values: array of intnumber; resultList: TFPList);
var i,j,k,pos:longint;
begin
  pos:=findMatch(values[0]);
  suffixs[pos].s.print;
  for i:=pos+1 to high(suffixs) do
    if cmpSequences(values,suffixs[i].s.values,0,suffixs[i].i)<>0 then break
    else suffixs[i].s.print;
  for i:=pos-1 downto 0 do
    if cmpSequences(values,suffixs[i].s.values,0,suffixs[i].i)<>0 then break
    else suffixs[i].s.print;
end;

end.

