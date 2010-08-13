program sequences;

{$mode objfpc}{$H+}



uses
  Classes, sysutils,
  calculation,  sequenceStoring;

type
  { TNode }

  TFunction=(base1,baseAlternate,unarySum,binaryAdd,binarySub,binaryMul);
  TNode=class
    typ: TFunction;
    seq: TSequence;
    a,b: TNode;
    procedure calculate;
  end;

{ TNode }

procedure TNode.calculate;
var i:longint;
begin
  if seq=nil then seq:=TSequence.create;
  for i:=0 to high(seq.values) do
    case typ of
      //Elementarfolgen
      base1: seq.values[i]:=1;
      baseAlternate: seq.values[i]:=i and 1;

      //Unäre Operatoren
      unarySum:
        if i=0 then seq.values[0]:=a.seq.values[0]
        else seq.values[i]:=seq.values[i-1]+a.seq.values[i];

      //Binäre Operatoren
      binaryAdd: seq.values[i]:=a.seq.values[i]+b.seq.values[i];
      binarySub: seq.values[i]:=a.seq.values[i]-b.seq.values[i];
      binaryMul: seq.values[i]:=a.seq.values[i]*b.seq.values[i];
    end;
end;

procedure generate(sequenceList: TSequenceStore);
var nodeList: TFPList;
    node: TNode;
    base: TFunction;
    i,j,lastCount,nextLastCount:longint;
begin
  nodeList:=TFPList.create;
  for base:=base1 to baseAlternate do begin
    node:=TNode.create;
    node.typ:=base;
    node.calculate;
    sequenceList.add(node.seq);
    nodeList.add(node);
  end;
  lastCount:=0;
  while nodeList.Count<100 do begin
    nextLastCount:=nodeList.count;
    for base:=unarySum to unarySum do
      for i:=lastCount to nextLastCount-1 do begin
        node:=TNode.create;
        node.typ:=base;
        node.a:=TNode(nodeList[i]);
        node.calculate;
        if sequenceList.add(node.seq) then
          nodeList.add(node);
      end;
    for base:=binaryAdd to binaryMul do
      for i:=lastCount to nextLastCount-1 do
        for j:=lastCount to i do begin
          node:=TNode.create;
          node.typ:=base;
          node.a:=TNode(nodeList[i]);
          node.b:=TNode(nodeList[j]);
          node.calculate;
          if sequenceList.add(node.seq) then
            nodeList.add(node);
        end;
    lastCount:=nextLastCount;
  end;
  nodeList.free;
end;


procedure find(sequenceList: TSequenceStore);
var seq: array of intnumber;
    i:longint;
begin
  setlength(seq,Paramcount);
  for i:=1 to Paramcount do
    seq[i-1]:=StrToInt(ParamStr(i));
  sequenceList.findAll(seq,nil);
end;

var sequenceList: TSequenceStore;


begin
  sequenceList:=TSequenceStore.create;
  generate(sequenceList);
  find(sequenceList);
  sequenceList.free;

  //readln;
end.

1            1, 1, 1, 1, 1,1     1                          [-1]
2            2, 2, 2, 2, 2       1+1
n            1, 2, 3, 4, 5,6     P(1)                       [-1] + 1
2n           2, 4, 6, 8,10,12    P(1+1)
n^2          1, 4,16,25,         P(1)*P(1)
n^2/2+n/2    1, 3, 6,10,15       P(P(1))
n^2/2+n/2-1  0, 1, 3, 6,10       P(P(1)-1)
                                 P(1)*P(1)/2+P(1)/2-1
             2, 6,10,18,28,40    P(P(1+1))
             2, 4, 8,16,32,64

P(P(1+1))


impossible

Also, number of unlabeled 2-gonal 2-trees with n 2-gons.
 A(x) = 1 + T(x)-T^2(x)/2+T(x^2)/2, where T(x) = x + x^2 + 2*x^3 +...
1, 1, 1, 1, 2, 3, 6, 11, 23, 47, 106, 235, 551, 1301, 3159, 7741, 19320, 48629, 123867, 317955, 823065, 2144505, 5623756, 14828074, 39299897, 104636890, 279793450, 751065460, 2023443032, 5469566585, 14830871802, 40330829030, 109972410221


Characteristic function of primes: 1 if n is prime else 0.
 a(n) = 1 iff n has exactly three prime factors (not necessarily distinct), else a(n) = 0. a(n) = 1 iff n is an element of A014612, else a(n) = 0.
Expansion of Pi in base 2.
Busy Beaver problem
Beethoven's Fifth Symphony;
a
