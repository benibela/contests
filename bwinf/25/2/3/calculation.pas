unit calculation;

{$mode objfpc}{$H+}
{$Q+}
interface

uses
  Classes, SysUtils,math;

type
  intnumber=int64; //Typ für ein Folgenelement
  Pintnumber=^intnumber;
  TSequenceValueBlock=array[0..100000] of int64; //Eine lange Folge
  PSequenceValueBlock=^TSequenceValueBlock;      //Zeiger auf das erste Element
  TOutputMode = (omNormal, omDerive, omLatex); //Gibt die Ausgabeart an

  { TMathExpressionNode }
  //Mathematische Operatoren mit konstanter Folge und Zugriff auf frühere Elemente
  TMathFunction=(mfbase1,mfbasePre1,mfbasePre2,mfbinaryAdd,mfbinarySub,mfbinaryMul);
  //Stellt einen Knoten des Syntaxbaums dar
  TMathExpressionNode=class
  private
    refcount: longint;        //Referenzzähler (Warum nur hat FPC keinen GC:-()
  public
    typ: TMathFunction;       //Operator
    a,b: TMathExpressionNode; //Ausdrücke auf die der Operator angewendet wird
    initSize,                 //Anzahl der Startwerte
    pre1Count,pre2Count: longint;//Vorfaktoren bei Zugriff auf frühere Elemente
    numberValue: intnumber;   //Zahlenwert, wenn der Ausdruck konstant ist
    seqRealLen:longint;       //Länge einer durch diesen Ausdruck bestimmten Folge
    constructor create();
    constructor create(_typ: TMathFunction);
    //Setzt die übergebenen Werte und überprüft sie
    function make(_typ: TMathFunction;_a,_b:TMathExpressionNode):boolean;
    //Berechnet einen Folgenwert
    function calculate(seq: PSequenceValueBlock):intnumber;
    //Liest den Ausdruck
    procedure readFromStream(stream:TStream);
    //Speichert den Ausdruck
    function writeToStream(stream:TStream): longint;
    //Wandelt ihn in einen String für Funktion namens functionName um
    function toString(outputMode: TOutputMode; functionName: string):string;
    procedure freeChildren; //Gibt die Unterknoten a und b frei
  end;







  { TSequenceCreator }
  
  //Eine abstrakte Folgedefinition
  TSequenceCreator=class
    refcount: longint;//Referenzzähler
    values: PSequenceValueBlock; //Die Folgenwerte
    realLen:longint;             //Die echte Länge der Folge
    //Berechnet die Werte in values aus der Folgendefinition
    procedure calculate(len:longint);virtual;abstract;
    //Liest die Folgendefinition
    procedure readFromStream(stream:TStream);virtual;abstract;
    //Speichert die Folgendefinition
    function writeToStream(stream:TStream): longint;virtual;abstract;
    //Gibt alle mit diesem Objekt verbundenen Objekte frei
    procedure freeChildren;virtual;abstract;
  end;

  { TRecursiveExpression }

  //Folgedefinition über Rekursion
  TRecursiveExpression=class(TSequenceCreator)
    expr: TMathExpressionNode;
    valueStart: array[0..1] of intnumber;
    constructor create();
    procedure calculate(len: longint);override;
    procedure readFromStream(stream:TStream);override;
    function writeToStream(stream:TStream): longint;override;
    //Gibt die Definition aus und benutzt dabei den angegeben Funktionsnamen
    function toString(outputMode: TOutputMode;
                      functionName: string):string;
    procedure freeChildren;override; //Löscht expr und alle weiteren Ausdrücke
  end;

  {TSequenceOperator}

  TSeqFunction=(sfbase1,sfbase2,sfbase5, //Konstante Folgen
                sfunarySum,sfUnaryMul,   //unäre Operatoren
                sfbinaryAdd,sfbinarySub,sfbinaryMul,sfbinaryPower//binäre Op.
                );
  //Folgedefinition über Folgenoperatoren
  TSequenceOperator=class(TSequenceCreator)
    typ: TSeqFunction;     //anzuwendende Rechenoperation
    a,b: TSequenceCreator; //Folgen, auf die diese angewendet werden
    numberOnly: boolean;   //Ist die Folge konstant?
    numberValue:intnumber; //Wenn ja, der konstante Wert
    constructor create;
    constructor create(_typ:TSeqFunction;_a,_b:TSequenceCreator);
    procedure update;      //Überprüft, ob die Folge konstant ist
    function equal(so:TSequenceOperator):boolean; //Vergleicht zwei Folgen
    //Berechnet die Folge aus den Variablen typ, a und b
    procedure calculate(len: longint);override;
    procedure readFromStream(stream:TStream);override;
    function writeToStream(stream:TStream): longint;override;
    //Wandelt die Definition in einen String, abhängig von der angegebenen
    //Variable um. Zu functions werden alle benötigten rekursiv Folgen hinzugefügt
    function toString(outputMode: TOutputMode; variable: longint;
                      var functions: string;
                      var functionCount: longint):string;
    procedure freeChildren;override; //Gibt a und b frei
  end;

  { TSequenceInfo }
  //Speichert die Definition einer Folge
  TSequenceInfo=class
    values: PSequenceValueBlock;        //Werte der Folge
    id,len: longint;                    //Nummer und Länge
    recursive:TRecursiveExpression;     //Rekursive Definition falls vorhanden
    sequenceOperator:TSequenceOperator; //Definition durch Operatoren  " "
    standAlone: boolean;                //Keine gemeinsame Speichernutzung
    suffixStart: longint;               //Startposition der gesuchten Folge
    procedure print(outputMode: TOutputMode);//Gibt die Folge und Definition aus
    procedure readFromStream(stream:TStream);//Lädt die Definitionen
    function writeToStream(stream:TStream): longint;//Speichert die Definitionen
    destructor destroy;override;
  end;


const INT_NAN:intnumber=-9223372036854775808; //Wert für undefinierte Zahlen
      NORMAL_INT_NAN:longint=MaxInt;          // "    "        "       "
      MIN_SEQ_LEN     = 10;                   //Mindestlänge einer Folge
      REC_CREATION_ID = $1;  //Nummer für eine rekursiv definierte Folge
      SEQ_CREATION_ID = $2;  //Nummer für eine durch Operatoren definierte Folge
      //Alle möglichen Variablenamen in der Reihenfolge ihrer Verwendung
      VARIABLE_NAMES:string='nijklrstuvwmxyzabcdefghopqABCDEFGHIJKLMNOPQRSTUVWXYZ';
implementation

{ TMathExpressionNode }

constructor TMathExpressionNode.create();
begin
  refcount:=1;
end;

//Konstruktor für Basisausdrücke
constructor TMathExpressionNode.create(_typ: TMathFunction);
begin
  refcount:=1;
  make(_typ,nil,nil);
end;







//Setzt die übergebenen Werte und überprüft sie
//Hierzu wird die Zahl der Startwerte aus a und b übernommen
//Die Vorfaktoren der Zugriffe auf frühere Elemente ermittelt und entsprechend
//kombiniert. (addiert bei Addition, ... )
//Stellt sich heraus, dass einer Vorfaktoren 0 ergibt, ist die Konstruktion
//sinnlos. Weiterhin wird überprüft, ob die Folge konstant ist
function TMathExpressionNode.make(_typ: TMathFunction; _a,
  _b: TMathExpressionNode):boolean;
begin
  typ:=_typ;
  a:=_a;
  b:=_b;
  case typ of
    //Basisausdrücke (konstanter Wert, Zugriff auf frühere Elemente)
    mfbase1: begin
      initSize:=0;
      numberValue:=1;
    end;
    mfbasePre1: begin
      initSize:=1;
      pre1Count:=1;
      numberValue:=INT_NAN;
    end;
    mfbasePre2: begin
      initSize:=2;
      pre2Count:=1;
      numberValue:=INT_NAN;
    end;
    //Binäre Operatoren
    else begin
      if a.initSize>b.initSize then initSize:=a.initSize
      else initSize:=b.initSize;
      //Vorfaktor für das vorherige Element
      if (a.pre1Count=NORMAL_INT_NAN) or (b.pre1Count=NORMAL_INT_NAN) then
        pre1Count:=NORMAL_INT_NAN
       else case typ of
        mfbinaryAdd: pre1Count:=a.pre1Count+b.pre1Count;
        mfbinarySub: pre1Count:=a.pre1Count-b.pre1Count;
        mfbinaryMul: pre1Count:=NORMAL_INT_NAN;
       end;
      //Vorfaktor für das vorvorherige
      if (a.pre2Count=NORMAL_INT_NAN) or (b.pre2Count=NORMAL_INT_NAN) then
        pre2Count:=NORMAL_INT_NAN
       else case typ of
        mfbinaryAdd: pre2Count:=a.pre2Count+b.pre2Count;
        mfbinarySub: pre2Count:=a.pre2Count-b.pre2Count;
        mfbinaryMul: pre2Count:=NORMAL_INT_NAN;
       end;
      //Überprüfung auf Konstanz
      if (initSize=0) and (a.numberValue<>INT_NAN) and (b.numberValue<>INT_NAN) then
        numberValue:=a.numberValue+b.numberValue
       else
        numberValue:=INT_NAN;
    end;
  end;
  //Überprüfung auf verschwindende Vorfaktoren
  result:=(pre1Count<>0) and
          ((pre2Count<>0) or (initSize<2));
end;

//Berechnet ein Element einer Folge und gibt den Wert zurück
//seq^[0] sollte das aktuelle Element sein seq^[-1] das vorherige ...
function TMathExpressionNode.calculate(seq: PSequenceValueBlock): intnumber;
begin
  if numberValue<>INT_NAN then exit(numberValue);
  case typ of
    mfbase1:    result:=1;
    mfbasePre1: result:=(Pintnumber(seq)-1)^;
    mfbasePre2: result:=(Pintnumber(seq)-2)^;
    mfbinaryAdd: result:=a.calculate(seq)+b.calculate(seq);
    mfbinarySub: result:=a.calculate(seq)-b.calculate(seq);
    mfbinaryMul: result:=a.calculate(seq)*b.calculate(seq);
  end;
end;

//Liest den Ausdruck aus einer Datei
procedure TMathExpressionNode.readFromStream(stream: TStream);
begin
  typ:=TMathFunction(stream.ReadByte);
  if typ>=mfbinaryAdd then begin
    //Bei einer binären Operation Teilausdrücke laden
    a:=TMathExpressionNode.Create;
    b:=TMathExpressionNode.Create;
    a.readFromStream(stream);
    b.readFromStream(stream);
  end;
  //Überprüfen (konstanten Wert ermitteln, falls vorhanden)
  make(typ,a,b);
end;

//Speichern
function TMathExpressionNode.writeToStream(stream: TStream): longint;
begin
  result:=1;
  stream.WriteByte(byte(typ));
  if typ>=mfbinaryAdd then begin //Teilausdrücke falls vorhanden auch speichern
    Result+=a.writeToStream(stream);
    Result+=b.writeToStream(stream);
  end;
end;






//Umwandlung in einen String
function TMathExpressionNode.toString(outputMode: TOutputMode;
                                      functionName: string): string;
begin
  if numberValue<>INT_NAN then
    exit(IntToStr(numberValue)); //konstanten Wert ausgeben, falls vorhanden
  case typ of //Ansonsten
    mfbase1:    result:='1';
    mfbasePre1: result:=functionName+'(n-1)';
    mfbasePre2: result:=functionName+'(n-2)';
    mfbinaryAdd: result:='('+a.toString(outputMode,functionName)+')+('+
                             b.toString(outputMode,functionName)+')';
    mfbinarySub: result:='('+a.toString(outputMode,functionName)+')-('+
                             b.toString(outputMode,functionName)+')';
    mfbinaryMul: result:='('+a.toString(outputMode,functionName)+')*('+
                             b.toString(outputMode,functionName)+')';
  end;
end;

//Gibt die Kindausdrücke frei
procedure TMathExpressionNode.freeChildren;
begin
  if a<>nil then begin
    a.refcount-=1;
    if a.refcount<=0 then begin;
      a.freeChildren;
      a.free;
    end;
  end;
  if b<>nil then begin
    b.refcount-=1;
    if b.refcount<=0 then begin;
      b.freeChildren;
      b.free;
    end;
  end;
end;


{ TRecursiveExpression }

constructor TRecursiveExpression.create();
begin
  refcount:=1;
end;

//Berechnet die Folge gemäß ihrem rekursiven Ausdruck
procedure TRecursiveExpression.calculate(len: longint);
var i,j:longint;
begin
  move(valueStart[0],values^[0],2*sizeof(intnumber)); //Startwerte übernehmen
  realLen:=len; //von einer Folge ohne Überlauf ausgehen
  for i:=expr.initSize to len-1 do
    try
      values^[i]:=expr.calculate(@values^[i]); //Jedes Element einzeln berechnen
    except
      //Überlauf
      realLen:=i; //Folge abschneiden
      if realLen<MIN_SEQ_LEN then exit; //Zu kurz für eine Speicherung
      for j:=i to len-1 do //Rest auf unbekannt setzten, falls die Folge ok ist
        values^[j]:=INT_NAN;
      exit;
    end;
end;

//Aus einer Datei laden
procedure TRecursiveExpression.readFromStream(stream: TStream);
begin
  //Startwerte
  stream.ReadBuffer(valueStart[0],2*sizeof(intnumber));
  //Rekursive Definition
  expr:=TMathExpressionNode.Create;
  expr.readFromStream(stream);
end;

//Speicher
function TRecursiveExpression.writeToStream(stream: TStream): longint;
begin
  //Startwerte
  stream.WriteBuffer(values^[0],2*sizeof(intnumber));
  //Rekursive Definition (und Bytes zählen)
  Result:=2*sizeof(intnumber)+expr.writeToStream(stream);
end;

//In einen String umwandeln
function TRecursiveExpression.toString(outputMode: TOutputMode;
                                    functionName: string): string;
var i:longint;
begin
  result:='';
  case outputMode of
    omDerive: begin
      //Für Derive werden die Startwerte in eine IF-Anweisung geschrieben
      Result:=functionName+'(n):=';
      for i:=0 to expr.initSize-1 do
        result+='IF(n='+IntToStr(i)+','+IntToStr(valueStart[i])+',';
      result+=expr.toString(outputMode,functionName); //Rekursive Definition
      for i:=0 to expr.initSize-1 do
        result+=')';
    end;
    else begin
      if outputMode=omLatex then result:='$';
      //Startwerte hintereinander ausgeben
      for i:=0 to expr.initSize-1do
        result+=functionName+'('+IntToStr(i)+') = '+IntToStr(valueStart[i])+'; ';
      //Rekursive Definition ausgeben
      result+=functionName+'(n) = '+expr.toString(outputMode,functionName);
      if outputMode=omLatex then result+='$';
    end;
  end;;
end;

//Rekursive Definition löschen
procedure TRecursiveExpression.freeChildren;
begin
  if expr<>nil then begin
    expr.refcount-=1;
    if expr.refcount<0 then begin
      expr.freeChildren;
      expr.free;
    end;
  end;
end;

{ TSequenceOperator }

constructor TSequenceOperator.create;
begin
  refcount:=1;
  numberValue:=INT_NAN;
end;

constructor TSequenceOperator.create(_typ: TSeqFunction; _a,_b: TSequenceCreator
  );
begin
  refcount:=1;
  typ:=_typ;
  a:=_a;
  b:=_b;
  update;
end;

//Überprüft, ob die Folge konstant ist
procedure TSequenceOperator.update;
var soa,sob: TSequenceOperator; //a und b als TSequenceOperator
begin
  numberValue:=INT_NAN;
  numberOnly:=false;
  //Umwandlung von a und b in TSequenceOperator falls möglich
  if typ>=sfunarySum then
    if (a is TSequenceOperator) then soa:=TSequenceOperator(a)
    else exit;
  if typ>=sfbinaryAdd then
    if (b is TSequenceOperator) then sob:=TSequenceOperator(b)
    else exit;
  try
    case typ of
      //Basisausdrücke sind immer konstant
      sfbase1: numberValue:=1;
      sfbase2: numberValue:=2;
      sfbase5: numberValue:=5;
      //Summe kann konstant 0 sein
      sfunarySum:
        if soa.numberValue=0 then numberValue:=0
        else numberValue:=INT_NAN;
      //Produkt kann konstant 0 oder 1 sein
      sfUnaryMul:
        if (soa.numberValue = 0) or (soa.numberValue = 1) then
          numberValue:=soa.numberValue
        else numberValue:=INT_NAN;
      //Binäre Operatoren sind konstant, falls beide Kindfolgen konstant sind
      sfbinaryAdd:
        if (soa.numberValue<>INT_NAN) and (sob.numberValue<>INT_NAN) then
          numberValue:=soa.numberValue + sob.numberValue
         else
          numberValue:=INT_NAN;
      sfbinarySub:
        if (soa.numberValue<>INT_NAN) and (sob.numberValue<>INT_NAN) then
          numberValue:=soa.numberValue - sob.numberValue
         else
          numberValue:=INT_NAN;
      sfbinaryMul:
        if (soa.numberValue<>INT_NAN) and (sob.numberValue<>INT_NAN) then
          numberValue:=soa.numberValue * sob.numberValue
         else
          numberValue:=INT_NAN;
      sfbinaryPower:
        if (soa.numberValue<>INT_NAN) and (sob.numberValue<>INT_NAN) then
          numberValue:=soa.numberValue**sob.numberValue
         else
          numberValue:=INT_NAN;
    end;
  except
    numberValue:=INT_NAN; //Überlauf
  end;
  numberOnly:=numberValue<>INT_NAN;
end;

//Überprüft zwei Folgen auf Gleichheit
function TSequenceOperator.equal(so: TSequenceOperator): boolean;
var i:longint;
begin
  if typ=so.typ then begin
    //Gleiche Basisausdrücke sind immer gleich
    if typ in [sfbase1,sfbase2,sfbase5{,sfbaseAlternate}] then exit(true);
    //Unäre Operatoren sind gleich, wenn Parameter gleich sind
    if typ in [sfUnaryMul,sfunarySum] then
      if (a is TSequenceOperator) and (b is TSequenceOperator) then
        exit(TSequenceOperator(a).equal(TSequenceOperator(so.a)));
  end;
  //Ungleiche Länge => ungleiche Folge
  if realLen<>so.realLen then exit(false);
  //Element-Element Vergleich
  result:=true;
  for i:=0 to realLen-1 do
    if so.values^[i]<>values^[i] then exit(false);
end;

//Berechnet die Werte der Folge
procedure TSequenceOperator.calculate(len:longint);
var i,j:longint;
begin
  if values=nil then exit;
  realLen:=len;
  for i:=0 to len-1 do
    try
      //Überlauf, wenn einer der Werte undefiniert ist
      if typ>=sfunarySum then if a.values^[i]=INT_NAN then
        raise EIntOverflow.Create('');
      if typ>=sfbinaryAdd then if b.values^[i]=INT_NAN then
        raise EIntOverflow.Create('');
      case typ of
        //Elementarfolgen
        sfbase1: values^[i]:=1;
        sfbase2: values^[i]:=2;
        sfbase5: values^[i]:=5;

        //Unäre Operatoren
        sfunarySum:
          if i=0 then values^[0]:=a.values^[0]
          else values^[i]:=values^[i-1]+a.values^[i];
        sfUnaryMul:
          if i=0 then values^[0]:=a.values^[0]
          else values^[i]:=values^[i-1]*a.values^[i];

        //Binäre Operatoren
        sfbinaryAdd: values^[i]:=a.values^[i]+b.values^[i];
        sfbinarySub: values^[i]:=a.values^[i]-b.values^[i];
        sfbinaryMul: values^[i]:=a.values^[i]*b.values^[i];
        sfbinaryPower: begin
          values^[i]:=a.values^[i]**b.values^[i];
          if b.values^[i]<0 then raise EMathError.create('');
        end;
      end;
    except
      realLen:=i;
      if realLen<MIN_SEQ_LEN then exit;
      for j:=i to len-1 do
        values^[j]:=INT_NAN;
      break;
    end;
end;




//Aus Datei laden
procedure TSequenceOperator.readFromStream(stream: TStream);
begin
  typ:=TSeqFunction( stream.ReadByte);
  //Unterschiedlich Kindfolgen je nach Typ
  if typ>=sfunarySum then begin
    case stream.ReadByte of
      REC_CREATION_ID: a:=TRecursiveExpression.Create;
      SEQ_CREATION_ID: a:=TSequenceOperator.Create;
      else raise Exception.Create('Unbekannter Typ');
    end;
    a.readFromStream(stream);
  end;
  if typ>=sfbinaryAdd then begin
    case stream.ReadByte of
      REC_CREATION_ID: b:=TRecursiveExpression.Create;
      SEQ_CREATION_ID: b:=TSequenceOperator.Create;
      else raise Exception.Create('Unbekannter Typ');
    end;
    b.readFromStream(stream);
  end;
  update;
end;

//Speichern
function TSequenceOperator.writeToStream(stream: TStream): longint;
begin
  result:=1;
  stream.WriteByte(byte(typ));
  //Kindfolgen mitsamt Typ speichern
  if typ>=sfunarySum then begin
    if a is TSequenceOperator then stream.WriteByte(SEQ_CREATION_ID)
    else if a is TRecursiveExpression then stream.WriteByte(REC_CREATION_ID)
    else raise Exception.Create('Unbekannter Typ');
    result+=a.writeToStream(stream)+1;
  end;
  if typ>=sfbinaryAdd then begin
    if b is TSequenceOperator then stream.WriteByte(SEQ_CREATION_ID)
    else if b is TRecursiveExpression then stream.WriteByte(REC_CREATION_ID)
    else raise Exception.Create('Unbekannter Typ');
    result+=b.writeToStream(stream)+1;
  end;
end;

//In einen String umwandeln
//variable ist der Index der abhängigen Variable, functionCount gibt die Zahl
//der benötigten Rekursionsfolgen zurück und functions enthält diese Folgen
//als Strings
function TSequenceOperator.toString(outputMode: TOutputMode; variable: longint;
                                   var functions: string;
                                   var functionCount: longint): string;

  //Wandelt eine rekursive Folge in einen String um und hängt sie an functions
  function addRecursiveSequence(rec: TRecursiveExpression):string;
  begin
    inc(functionCount);
    if functions<>'' then functions+=LineEnding;
    case outputMode of
      omLatex: begin
        Result:='g_{'+inttostr(functionCount)+'}'; //Tiefstellen des Index
        functions+='\hspace*{20mm}';               //Einrücken
      end;
      else begin
        Result:='g'+inttostr(functionCount);
        functions+='  '; //Einrücken
      end;
    end;
    functions+=rec.toString(outputMode,Result);
    if outputMode=omLatex then functions+='\newline';
    Result+='('+VARIABLE_NAMES[variable]+')';
  end;
var strA,strB: string; //a und b als String
    soa,sob: TSequenceOperator; //a und b als TSequenceOperator (falls möglich)
begin
  //Konstanter Wert bei konstanter Folge
  if numberValue<>INT_NAN then exit(IntToStr(numberValue));
  //Abhängige Variable unbekannt
  if variable>length(VARIABLE_NAMES) then exit('?');
  //Summe von 1 bis zur Variablen ergibt die Variable selbst
  if (typ=sfunarySum) and (a is TSequenceOperator) and
     (TSequenceOperator(a).typ=sfbase1) then
     exit(VARIABLE_NAMES[variable]);
  //Summe von konstanter Folge bis zur Variablen ergibt ihr Vielfaches
  if (typ=sfunarySum) and (a is TSequenceOperator) and
     (TSequenceOperator(a).numberValue<>INT_NAN) then
       exit('('+IntToStr(TSequenceOperator(a).numberValue)+'*'+
                VARIABLE_NAMES[variable]+')');
  //Umwandeln von a und b in strings und TSequenceOperators
  if a is TRecursiveExpression then begin
    strA:=addRecursiveSequence(TRecursiveExpression(a));
    soa:=nil;
  end else soa:=TSequenceOperator(a);
  if b is TRecursiveExpression then begin
    strB:=addRecursiveSequence(TRecursiveExpression(b));
    sob:=nil;
  end else sob:=TSequenceOperator(b);
  case typ of
    sfunarySum,sfUnaryMul:
      if soa<>nil then
        strA:=soa.toString(outputMode,variable+1,functions,functionCount);
    sfbinaryAdd..sfbinaryPower: begin
      if soa<>nil then
        strA:=soa.toString(outputMode,variable,functions,functionCount);
      if sob<>nil then
        strB:=sob.toString(outputMode,variable,functions,functionCount)
    end;
    else raise Exception.Create('Unbekannter Operator: '+IntToStr(byte(typ)));
  end;
  //Umwandlung von Ausgabenmodus unabhängigen Operatoren
  case typ of
    sfbase1:     exit('1'); //Konstante Werte sollten eigenltich unnötig sein
    sfbase2:     exit('2'); //Aber sicher ist sicher
    sfbase5:     exit('5');
    sfbinaryAdd: exit('('+strA+'+'+strB+')');
    sfbinarySub: exit('('+strA+'-'+strB+')');
    sfbinaryMul: exit('('+strA+'*'+strB+')');
  end;
  //Umwandlung von Ausgabenmodus abhängigen Operatoren
  case outputMode of
    omNormal: case typ of
      sfunarySum: result:='P('+strA+')';
      sfUnaryMul: result:='M('+strA+')';
      sfbinaryPower: result:='('+strA+'^'+strB+')';
    end;
    omDerive: case typ of
      sfunarySum:
        result:='sum('+strA+','+
                       VARIABLE_NAMES[variable+1]+',1,'+
                       VARIABLE_NAMES[variable]+')';
      sfUnaryMul:
        result:='product('+strA+','+
                           VARIABLE_NAMES[variable+1]+',1,'+
                           VARIABLE_NAMES[variable]+')';
      sfbinaryPower: result:='('+strA+'^'+strB+')';
    end;
    omLatex: case typ of
      sfunarySum:
        result:='\sum\limits_{'+
                              VARIABLE_NAMES[variable+1]+'=1}^'+
                              VARIABLE_NAMES[variable]+'\left('+
                      strA+'\right)';
      sfUnaryMul:
        result:='\prod\limits_{'+
                               VARIABLE_NAMES[variable+1]+'=1}^'+
                               VARIABLE_NAMES[variable]+'\left('+
                               strA+'\right)';
      sfbinaryPower: result:=strA+'^{'+strB+'}';
    end;
  end;

end;

//Kinder freigeben
procedure TSequenceOperator.freeChildren;
begin
  if a<>nil then begin
    a.refcount-=1;
    if a.refcount<=0 then begin
      a.freeChildren;
      a.free;
    end;
  end;
  if b<>nil then begin
    b.refcount-=1;
    if b.refcount<=0 then begin
      b.freeChildren;
      b.free;
    end;
  end;
end;

{ TSequenceInfo }

//Ausgabe einer Folge als komma-separierte Liste (mit Klammern bei Derive)
procedure printSequence(outputMode:ToutputMode; seq:PSequenceValueBlock; len:longint);
var i:longint;
begin
  if outputMode=omDerive then write('[');
  write(seq^[0]);
  for i:=1 to len-1 do begin
    if seq^[i]=INT_NAN then break;
    write(', ',seq^[i]);
  end;
  if outputMode=omDerive then write(']');
  writeln();
end;

//Ausgabe einer Folge mit Definition
procedure TSequenceInfo.print(outputMode: TOutputMode);
var fCount:longint;       //Zahl der benötigten rekursiven Funktionen
    seq,functions:string; //Folgendefinition und benötigte Funktionen
begin
  printSequence(outputMode,values,len); //Folge selbst ausgeben
  if outputMode=omLatex then writeln('\newline'); //Neue Zeile
  //Definition durch Folgenoperatoren
  if sequenceOperator<>nil then begin
    fCount:=0; functions:='';
    seq:=sequenceOperator.toString(outputMode,1,functions,fCount);
    if fCount<>0 then writeln(functions); //Benötigte rekursiv definierte Folgen
    if outputMode=omLatex then write('Definition: $')
    else write('Definition: ');
    write(seq);
    if outputMode=omLatex then writeln('$') else writeln;
  end;
  //Rekursive Definition
  if recursive<>nil then begin
    if sequenceOperator<>nil then
      if outputMode=omLatex then writeln('\newline') //Neue Zeile
      else writeln;
    write('Definition: ',recursive.toString(outputMode,'f'));
  end;
  writeln();
  if outputMode=omLatex then writeln(); //Neuer Absatz
end;

//Folgendefinition aus Datei lesen
procedure TSequenceInfo.readFromStream(stream: TStream);
begin
  if stream.ReadByte=REC_CREATION_ID then begin
    recursive:=TRecursiveExpression.Create;
    recursive.values:=values;
    recursive.readFromStream(stream);
  end;
  if stream.ReadByte=SEQ_CREATION_ID then begin
    sequenceOperator:=TSequenceOperator.Create;
    sequenceOperator.values:=values;
    sequenceOperator.readFromStream(stream);
  end;
end;

//Folgendefinitionen in Datei speichern
function TSequenceInfo.writeToStream(stream: TStream): longint;
begin
  result:=2;
  if recursive<>nil then begin
    stream.WriteByte(REC_CREATION_ID);
    Result+=recursive.writeToStream(stream);
  end else stream.WriteByte(0);
  if sequenceOperator<>nil then begin
    stream.WriteByte(SEQ_CREATION_ID);
    Result+=sequenceOperator.writeToStream(stream);
  end else stream.WriteByte(0);
end;

//Folgendefinitionen löschen, wenn sie keinen gemeinsam genutzten Speicherplatz
//enthalten (Bei der Erzeugung hängen alle Syntaxbäume zusammen)
destructor TSequenceInfo.destroy;
begin
  if standAlone then begin
    Freemem(values);
    if recursive<>nil then begin
      recursive.freeChildren;
      recursive.free;
    end;
    if sequenceOperator<>nil then begin
      sequenceOperator.freeChildren;
      sequenceOperator.free;
    end;
  end;
  inherited;
end;
end.

