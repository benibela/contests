{$define debug}
unit a2_u;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ComCtrls;

type
  BigNumber=array of integer;
  TForm1 = class(TForm)
    folge: TEdit;                //Eingabefeld für die gebaute Folge von Übungen
    count: TButton;              //Button zum Zählen aller Möglichkeiten
    list: TButton;               //Button zum Auflisten aller Möglichkeiten
    calculatedCount: TEdit;      //Ausgabefeld für die Anzahl
    possibilities: TMemo;        //Ausgabefeld für die Möglichkeiten
    ProgressBar1: TProgressBar;  //Fortschrittsanzeige während der Berechnung
    fromFile: TRadioButton;      //gibt der Wert in folge eine Datei an
    direct: TRadioButton;        //  oder eine Folge
    Title: TLabel;               //design
    Label1: TLabel;              //design
    procedure listClick(Sender: TObject);
    procedure countClick(Sender: TObject);
    procedure directClick(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
const BASE=1000000000;

//=========================Zählen aller Teilfolgen==============================
{ Addiert zwei Zahlen n1 und n2 gleicher Länge und speichert das Ergebnis in n1

(*) Notationen
             n1[i]         =  i-te Ziffer von n1 (n1[0] ist die höchstwertige)
             n2[i]         =  i-te Ziffer von n2 (n2[0] ist die höchstwertige)
             n1#[i]        =  i-te Ziffer von n1, vor Aufruf der Funktion
             n1'[i]        =  i-te Ziffer von n1, nach der nächsten Anweisung
             length(n1)    =  Anzahl der Ziffern in n1
             length(n2)    =  Anzahl der Ziffern in n2     (wie bei Arrays)
             length(n1)    =  m + 1
             BASE          = 1000000000 = Die verwendete Zahlenbasis

(*) Annahme:1. length(n1)        =  length(n2)
            2. 0  <=  n1[i]      <= BASE - 1 für alle i
            3. 0  <=  n2[i]       <= BASE - 1 für alle i
            4. n1[0] + n2[0] + 1 < BASE
            4. n1[i], n2[i]       ist definiert für 0<=i<=m
               (folgt aber schon aus den Delphiarrayspezifikationen)


(*) Gewünschtes Ergebnis:
     1. SUMME_i=0^m(n1'[i]*BASE^(m-i)) =  SUMME(n1#[i]*BASE^(m-i)) + SUMME(n2[i]*BASE^(m-i))     //TODO: Summenzeichen
     2. 0  <=  n1'[i]  <=  BASE - 1 für alle 0<=i<=m
}
procedure add(n1:BigNumber;const n2:BigNumber);
var i:integer;
    overflow: boolean;
begin
  {Arrayzugriffe wie n[i] sind definiert, wenn 0<=i<=m}

  overflow:=false;
  for i:=high(n1){m} downto 0 do begin //Es gilt immer: 0<=i<=m
    { n1[i] = n1#[i], da nur die Ziffern n[j] mit j > i verändert wurden.
      (Der Ausdruck ist definiert, da wegen der Schleife 0<=i<=m ist)
    }
    if overflow then begin //Fall 1: overflow  = true
       {Voraussetzung:
          SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i+1^m(n1#[k]*BASE^(m-k)) + SUMME_k=i+1^m(n2[k]*BASE^(m-k))-BASE^(m-i)

          (erfüllt durch letzten Schleifendurchlauf)

          (Arrayzugriffe auf k sind definiert, da auf Grund der Summendefinitionen
           i+1<=k<=m gilt, also 0<=k<=m)
       }
       n1[i]:=n1[i]+n2[i]+1
       { Folgen der letzten Anweisung:
          SUMME_k=i^m(n1[k]*BASE^(m-k))
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + n1[i]*BASE^(m-i)             | Zerlegung der Summe
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + (n1#[i] + n2[i] + 1) *BASE^(m-i) | Zuweisung einsetzen
          = SUMME_k=i+1^m(n1#[k]*BASE^(m-k)) + SUMME_k=i+1^m(n2[k]*BASE^(m-k))-BASE^(m-i) + (n1#[i] + n2[i] + 1) *BASE^(m-i) | Vorraussetzung einfügen
          = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k)) | Summen zusammenfassen

         (Wie man an den Summen erkennen kann, kommen in den Gleichungen nur Arrayzugriffe
         n1[k] und n2[k] mit i<=k<=m und i+1<=k<=m vor, die definiert sind, wegen der Schleife 0<=i<=m ist)

         Es ist nicht garantiert, dass n1#[i] + n2[i] + 1 < BASE, also kann nun
         gelten: n1[i] >= BASE
         Da n1#[i] >= 0 und n2[i] >= 0 ist auch n1[i] >= 0.
         Da n1#[i] <= BASE - 1 und n2[i] <= BASE - 1 ist n1 <= 2*BASE - 1
         (Ausdrücke sind definiert, da wegen der Schleife 0<=i<=m ist)
       }
    end else begin         //Fall 2: overflow  = false
      {Voraussetzung:
         SUMME_k=i+1^m(n1[i]*BASE^(m-i)) = SUMME_k=i+1^m(n1#[i]*BASE^(m-i)) + SUMME_k=i+1^m(n2[i]*BASE^(m-i))

         (im ersten Durchlauf sind beide Seiten 0, da dann i+1>m, ansonsten ist
          sie durch den letzten Schleifendurchlauf erfüllt)

         (Wie man an den Summendef. erkennen kann, kommen in den Gleichungen nur Arrayzugriffe
         n1[k] und n2[k] mit i+1<=k<=m vor, die definiert sind, wegen der Schleife 0<=i<=m ist)
      }
      n1[i]:=n1[i]+n2[i];
       { Folgen der letzten Anweisung:
          SUMME_k=i^m(n1[k]*BASE^(m-k))
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + n1[i]*BASE^(m-i)             | Zerlegung der Summe
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + (n1#[i] + n2[i]) *BASE^(m-i) | Zuweisung einsetzen
          = SUMME_k=i+1^m(n1#[k]*BASE^(m-k)) + SUMME_k=i+1^m(n2[k]*BASE^(m-k))  + (n1#[i] + n2[i]) *BASE^(m-i) | Vorraussetzung einfügen
          = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k)) | Summen zusammenfassen

         (Wie man an den Summen erkennen kann, kommen in den Gleichungen nur Arrayzugriffe
         n1[k] und n2[k] mit i<=k<=m und i+1<=k<=m vor, die definiert sind, wegen der Schleife 0<=i<=m ist)

         Es ist nicht garantiert, dass n1#[i] + n2[i] < BASE, also kann nun
         gelten: n1[i] >= BASE
         Da n1#[i] >= 0 und n2[i] >= 0 ist auch n1[i] >= 0.
         Da n1#[i] <= BASE - 1 und n2[i] <= BASE - 1 ist n1 <= 2*BASE - 2

         (Ausdrücke sind definiert, da wegen der Schleife 0<=i<=m ist)
       }
    end;
    { Es gilt nun:
      1. SUMME_k=i^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k))
      2. n1[i] >= 0
      3. n1[i] <= 2*BASE - 1

      Möglicherweise ist aber n1[i] >= BASE

      (Ausdrücke sind definiert, da nur Arrayzugriffe n1[k], n2[k] und n1[i] mit i<=k<=m
      vorkommen und 0<=i<=m ist)
    }
    if n1[i]<BASE then begin
      {
        Da n1[i] < BASE ist, sind die an das Ergebnis gestellten Bedingungen erfüllt.
      }
      overflow:=false
      {
        Da nun overflow=false ist, wird nun im nächsten Durchlauf Fall 2 eintreten,
        und die dort beschriebene Vorraussetzung ist erfüllt.
      }
    end else begin
      { Es gilt: n1[i] >= BASE.

        Da n1[i] <= 2*BASE - 1 ist n1[i] - BASE <= BASE - 1.
        Da n1[i] >= BASE ist n1[i] - BASE >= 0

        Die zweite an das Ergebnis gestellt Bedingung ist also für n1'[i] erfüllt

        Für die Summe gilt dann:
           SUMME_k=i^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> n1[i]*BASE^(m-k) + SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> (n1'[i]+BASE)*BASE^(m-i) + SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> n1'[i]*BASE*(m-i) + BASE^(m-i+1) + SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> BASE^(m-i+1) + SUMME_k=i^m(n1'[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> SUMME_k=i^m(n1'[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k)) - BASE^(m-i+1)
       <=> SUMME_k=i^m(n1'[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) + SUMME_k=i^m(n2[k]*BASE^(m-k)) - BASE^(m-(i-1))

      (Ausdrücke sind definiert, da nur Arrayzugriffe n1[k], n2[k] und n1[i] mit i<=k<=m
      vorkommen und 0<=i<=m ist)

       Das heißt das im nächsten Durchlauf, wenn i' = i-1 ist, die Vorraussetung für Fall 1 erfüllt ist
      }
      n1[i]:=n1[i]-BASE;  //Vorraussetzungen erfüllen (s.o)
      overflow:=true;     //Fall 2 eintreten lassen
    end;
  end;

  {
    Da nach Annahme 4 gilt n1#[0] + n2[0] + 1 < BASE gilt, ist overflow = false.
    Das heißt, dass die Vorraussetzung aus Fall 2 gilt, und das ist gerade die
    an das Ergebnis gestellte Bedingung. (Wenn man die jetztige Situation als
    Schleifenanfang mit i=-1 betrachtet).
  }
end;

{ Subtrahiert zwei Zahlen mit gleicher Länge
(*) Notationen
             n1[i]         =  i-te Ziffer von n1 (n1[0] ist die höchstwertige)
             n2[i]         =  i-te Ziffer von n2 (n2[0] ist die höchstwertige)
             n1#[i]        =  i-te Ziffer von n1, vor Aufruf der Funktion
             n1'[i]        =  i-te Ziffer von n1, nach der nächsten Anweisung
             length(n1)    =  Anzahl der Ziffern in n1
             length(n2)    =  Anzahl der Ziffern in n2     (wie bei Arrays)
             length(n1)    =  m + 1
             BASE          = 1000000000 = Die verwendete Zahlenbasis

(*) Annahme:1. length(n1)        =  length(n2) = m - 1
            2. 0  <=  n1[i]      <= BASE - 1 für alle i
            3. 0  <=  n2[i]       <= BASE - 1 für alle i
            4
            5. n1[i], n2[i]       ist definiert für 0<=i<=m
               (folgt aber schon aus den Delphiarrayspezifikationen)

(*) Gewünschtes Ergebnis:
     1. SUMME_i=0^m(n1'[i]*BASE^(m-i)) =  SUMME(n1#[i]*BASE^(m-i)) - SUMME(n2[i]*BASE^(m-i))     //TODO: Summenzeichen
     2. 0  <=  n1'[i]  <=  BASE - 1 für alle i
}
procedure sub(n1:BigNumber;const n2:BigNumber);
var i:integer;
    overflow: boolean;
begin
  overflow:=False;
  for i:=high(n1){m} downto 0 do begin
    { n1[i] = n1#[i], da nur die Ziffern n[j] mit j > i verändert wurden. }
    if overflow then  begin
       {Voraussetzung:
          SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i+1^m(n1#[k]*BASE^(m-k)) - SUMME_k=i+1^m(n1[k]*BASE^(m-k))+BASE^(m-i)

         (erfüllt durch letzten Schleifendurchlauf)

         (Arrayzugriffe auf k sind definiert, da auf Grund der Summenindizes
          i+1<=k<=m gilt, also 0<=k<=m)
       }
      n1[i]:=n1[i]-n2[i]-1
       { Folgen der letzten Anweisung:
          SUMME_k=i^m(n1[k]*BASE^(m-k))
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + n1[i]*BASE^(m-i)                | Zerlegung der Summe
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + (n1#[i] - n2[i] - 1)*BASE^(m-i) | Zuweisung einsetzen
          = SUMME_k=i+1^m(n1#[k]*BASE^(m-k)) - SUMME_k=i+1^m(n2[k]*BASE^(m-k))+BASE^(m-i) + (n1#[i] + n2[i] + 1) *BASE^(m-i) | Vorraussetzung einfügen
          = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k)) | Summen zusammenfassen

         (Wie man an den Summen erkennen kann, kommen in den Gleichungen nur Arrayzugriffe
         n1[k] und n2[k] mit i<=k<=m und i+1<=k<=m vor, die definiert sind, wegen der Schleife 0<=i<=m ist)

         Es ist nicht garantiert, dass n1#[i] - n2[i] - 1 >= 0, also kann nun
         gelten: n1[i] < 0
         Da n1#[i] >= 0 und n2[i] < BASE ist auch n1[i] >= - BASE .

         (Ausdrücke sind definiert, da wegen der Schleife 0<=i<=m ist)

         (Wie man an den Summendef. erkennen kann, kommen in den Gleichungen nur Arrayzugriffe
         n1[k] und n2[k] mit i+1<=k<=m vor, die definiert sind, wegen der Schleife 0<=i<=m ist)
       }
    end else begin
      {Voraussetzung:
         SUMME_k=i+1^m(n1[i]*BASE^(m-i)) = SUMME_k=i+1^m(n1#[i]*BASE^(m-i)) - SUMME_k=i+1^m(n2[i]*BASE^(m-i))

         (im ersten Durchlauf sind beide Seiten 0, da dann i+1>m, ansonsten ist
          sie durch den letzten Schleifendurchlauf erfüllt)
      }
      n1[i]:=n1[i]-n2[i];
       { Folgen der letzten Anweisung:
          SUMME_k=i^m(n1[k]*BASE^(m-k))
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + n1[i]*BASE^(m-i)             | Zerlegung der Summe
          = SUMME_k=i+1^m(n1[k]*BASE^(m-k)) + (n1#[i] - n2[i]) *BASE^(m-i) | Zuweisung einsetzen
          = SUMME_k=i+1^m(n1#[k]*BASE^(m-k)) - SUMME_k=i+1^m(n2[k]*BASE^(m-k)) + (n1#[i] - n2[i])*BASE^(m-i) | Vorraussetzung einfügen
          = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k)) | Summen zusammenfassen

         (Wie man an den Summen erkennen kann, kommen in den Gleichungen nur Arrayzugriffe
         n1[k] und n2[k] mit i<=k<=m und i+1<=k<=m vor, die definiert sind, wegen der Schleife 0<=i<=m ist)

         Es ist nicht garantiert, dass n1#[i] >= n2[i] also kann nun gelten:
           n1[i] = n1#[i] - n2[i] < 0
         Da n1#[i] >= 0 und n2[i] < BASE ist auch n1[i] >= - BASE.

         (Ausdrücke sind definiert, da wegen der Schleife 0<=i<=m ist)
       }
    end;
    { Es gilt nun:
      1. SUMME_k=i^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k))
      2. n1[i] < BASE
      3. n1[i] >= - BASE - 1
      Möglicherweise ist aber n1[i] < 0

      (Ausdrücke sind definiert, da nur Arrayzugriffe n1[k], n2[k] und n1[i] mit i<=k<=m
      vorkommen und 0<=i<=m ist)
    }
    if n1[i]>=0 then begin
      {
        Da n1[i] >= 0 ist, sind die an das Ergebnis gestellten Bedingungen erfüllt.
      }
      overflow:=false
      {
        Da nun overflow=false ist, wird nun im nächsten Durchlauf Fall 2 eintreten,
        und die dort beschriebene Vorraussetzung ist erfüllt.
      }
    end else begin
      { Es gilt: n1[i] < 0

        Da n1[i] >= - BASE ist gilt: n[i] = n1[i] + BASE >= 0
        Da n1[i] < 0 ist gilt: n[i] = n1[i] + BASE < BASE.

        Die zweite an das Ergebnis gestellt Bedingung ist also für n1'[i] erfüllt.

        Für die Summe gilt dann:
           SUMME_k=i^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> n1[i]*BASE^(m-k) + SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> (n1'[i]-BASE)*BASE^(m-i) + SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> n1'[i]*BASE*(m-i) - BASE^(m-i+1) + SUMME_k=i+1^m(n1[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> - BASE^(m-i+1) + SUMME_k=i^m(n1'[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k))
       <=> SUMME_k=i^m(n1'[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k)) + BASE^(m-i+1)
       <=> SUMME_k=i^m(n1'[k]*BASE^(m-k)) = SUMME_k=i^m(n1#[k]*BASE^(m-k)) - SUMME_k=i^m(n2[k]*BASE^(m-k)) + BASE^(m-(i-1))

       Das heißt das im näcshten Durchlauf, wenn i' = i-1 ist, die Vorraussetung für Fall 1 erfüllt ist

      (Ausdrücke sind definiert, da nur Arrayzugriffe n1[k], n2[k] und n1[i] mit i<=k<=m
      vorkommen und 0<=i<=m ist)
      }
      overflow:=true;
      n1[i]:=n1[i]+BASE;
    end;
  end;
  {
    Da nach Annahme 4 gilt n1#[0] - n2[0] - 1 >=0 gilt, ist overflow = false.
    Das heißt, dass die Vorraussetzung aus Fall 2 gilt, und das ist gerade die
    an das Ergebnis gestellte Bedingung. (Wenn man die jetztige Situation als
    Schleifenanfang mit i=-1 betrachtet).
  }
end;


{ Wandelt die übergebene BigNummer in einen String um

(*) Notationen
             n[i]           =  i-te Ziffer von n (n[0] ist die höchstwertige)
             length(n)      =  Anzahl der Ziffern in n =  m + 1
             BASE           = 1000000000 = Die verwendete Zahlenbasis

             result[i]      =  i-te Ziffer vom Ergebnis
             length(result) =  Anzahl der Ziffern in result =  n

(*) Annahme: 0  <=  n1[i]      <= BASE - 1 für alle i
             n1[i]   ist definiert für 0<=i<=m

(*) Gewünschtes Ergebnis:
     1. SUMME_i=1^n(result[i]*10^(n-i)) =  SUMME_i=0^m(n[i]*BASE^(m-i))
     2. 0  <=  result[i]  <=  9 für alle i
     3. (result[1] <> 0) oder (result = '0')
}

function toStr(n: BigNumber):string;
var i:integer;
    t:string;
begin
  SetLength(result,length(n) * 9); //result[i] ist nun definiert für 1<=i<=n=(m+1)*9
  FillChar(result[1],length(result),ord('0'));

  {Es gilt nun die zweite Bedingung, nämlich dass result nur Zeichen zwischen
   0 und 9 enthalten darf}

  for i:=0 to high(n) do begin
    {Schleifeninvarianten:
      1. SUMME_j=1^i*9(result[j]*10^(n-j)) =  SUMME_j=0^i-1(n[j]*BASE^(m-j))
         (im ersten Durchlauf sind beide Seiten 0)
         (der Ausdruck ist definiert, da nur Arrayzugriffe result[j] mit 1<=j<=i*9<=m*9<=n
         und n[j] mit 0<=j<=i-1<=m-1 vorkommen)

      2. result[j] = 0 für alle j mit i*9<=j<=m*9+8
         (im ersten Durchlauf ist result[j] = 0 für alle j)
    }
    t:=IntToStr(n[i]);
    {Für temp gilt:
      1. SUMME_i=1^length(temp)temp[i*10^(length(temp)-i) = n[i]
      2. temp enthält nur Zeichen zwischen 0 und 9.
      3. length(temp) <= 9, da temp = n[i] < 1 000 000 000

     Folgen der nächsten Anweisung:
       Es werden length(t) Ziffern ersetzt, was zuerst einmal bedeutet:
                      result[j]       für (j<=i*9+9-length(t)) oder (j>i*9+9)
         result'[j] =
                      t[j - (i*9+9-length(t))]  sonst

         Da result[j] = 0 für alle j mit i*9<=j<=m*9+9, ist das äquivalent zu:
                      result[j]       für (j<=i*9+9-length(t)) oder (j>i*9+9)

         result'[j] = t[j - (i*9+9-length(t))]  für i*9+10-length(t)<=j<=i*9+9

                      0                         sonst

         SUMME_j=1^i*9+9(result'[j]*10^(n-j))
         = SUMME_j=1^i*9+9(result[j]*10^(n-j)) + SUMME_j=i*9+1^i*9+9(result'[j]*10^(n-j))
         = SUMME_j=1^i*9+9(result[j]*10^(n-j)) + SUMME_j=i*9 - (i*9+9-length(t))+1^i*9+9 - (i*9+9-length(t)) (result'[j+(i*9+9-length(t))]*10^(n-j-(i*9+9-length(t))))
         = SUMME_j=1^i*9+9(result[j]*10^(n-j)) + SUMME_j=1^length(t) (t[j]*10^(n-j-(i*9+9-length(t))))
         = SUMME_j=1^i*9+9(result[j]*10^(n-j)) + SUMME_j=1^length(t) (t[j]*10^(length(t)-j+n-i*9-9))
         = SUMME_j=1^i*9+9(result[j]*10^(n-j)) + SUMME_j=1^length(t) (t[j]*10^(length(t)-j))*10^(n-i*9-9)
         = SUMME_j=0^i-1(n[j]*BASE^(m-j)) + n[i]*10^(n-i*9-9)
         = SUMME_j=0^i-1(n[j]*BASE^(m-j)) + n[i]*10^((m+1)*9-i*9-9)
         = SUMME_j=0^i-1(n[j]*BASE^(m-j)) + n[i]*10^(m*9-i*9)
         = SUMME_j=0^i-1(n[j]*BASE^(m-j)) + n[i]*10^9(m-i)
         = SUMME_j=0^i-1(n[j]*BASE^(m-j)) + n[i]*BASE^(m-i)
         = SUMME_j=0^i(n[j]*BASE^(m-j))
           wodurch die Schleifeninvariante für den nächsten Durchlauf bewiesen ist

         (Alle Ausdrücke sind definiert, da bloß Arrayzugriffe auf result[j] mit 1<=j<=i*9+9<=n,
          auf result'[j] mit i*9+1<=j<=i*9+9 mit 1<=i*9+1, auf t[j] mit 1<=j<=length(t) und
          auf n[j] mit 0<=j<=i<=m erfolgen.
}
    move(t[1],result[i*9+10-length(t)],length(t));
  end;

  {Bedingungen 1 und 2 für das Ergbenis sind erfüllt, jetzt kommt die dritte}

  for i:=1 to length(result) do
    if result[i] <> '0' then begin  //also result[j]=0 für alle j<i
      {   SUMME_j=1^n(result'[j]*10^(n-j))
        = SUMME_j=i^n(result[j]*10^(n-j))
        = SUMME_j=1^n(result[j]*10^(n-j)) - SUMME_j=1^i-1(result[j]*10^(n-j))
        = SUMME_j=1^n(result[j]*10^(n-j)) - 0 da result[j]=0 für alle j<i
        = SUMME_j=0^m(n[j]*BASE^(m-i))
        alle Bedingungen sind erfüllt

        (Arrayszugriffe sind definiert, da nur Zugriffe auf result(')[j] mit
        1<=j<=n und auf n[j] mit 0<=j<=m erfolgen.
      }
      delete(result,1,i-1);
      exit;
    end;

  //das heißt result[i] = 0 für alle i, da ansonsten in der vorherigen
  //for-Schleife die Prozedur beendet worden wäre.
  Result:='0';
end;


(*
 Gegeben:
     str        eine Zeichenfolge
     n          length(str)

  Notation:
     str[1..i]  der String der entsteht, wenn man nur die ersten i Zeichen nimmt
     teilfolgen[1..i]  Die Anzahl der möglichen Teilfolgen von str[1..i]
     last[i]    Das größte j mit j<i und str[j] = str[i], oder 0 falls kein
                solches existiert

  Gesucht:
    Anzahl aller möglichen (unterschiedlichen) Teilfolgen von str,
    also teilfolgen[1..n]


*)
function countParts(const str: string):BigNumber;
var i:integer;
    lastParts: array[#0..#255] of BigNumber;
    c: char;

    numberLen,numberSize:integer;
    oldPossibilities:BigNumber;
begin
  numberLen:=trunc(length(str)*ln(2)/ln(BASE))+1;
  {
    BASE^numberLen
    = BASE^(trunc(length(str)*ln(2)/ln(BASE))+1)
    > BASE^(length(str)*ln(2)/ln(BASE)-1+1)
    = BASE^(length(str)*ln(2)/ln(BASE))
    = 2^length(str)


    = BASE*BASE^(trunc(length(str)*ln(2)/ln(BASE))) - 1
    > BASE*BASE^(length(str)*ln(2)/ln(BASE))-1) - 1

    = BASE*BASE^(trunc(length(str)*ln(2)/ln(BASE))) - 1
    = BASE*2^(trunc(length(str)) - 1
    = BASE*2^(trunc(length(str)) - 1
    > BASE*2^(length(str)-1)
    = 0.5*BASE*2^length(str)
    > 2*2^length(str)


  }
  numberSize:=numberLen*sizeof(integer);

  SetLength(result,numberLen);
  SetLength(oldPossibilities,numberLen);
  zeromemory(@result[0],numberSize);
  Result[high(result)]:=1;

  ZeroMemory(@lastParts,sizeof(lastParts));

  Form1.ProgressBar1.Max:=length(str);

  {Es gilt:
    1. result = 1 = Anzahl der möglichen Teilfolgen eines leeren Strings
    2. last[1] = 0, da vor dem ersten Zeichen kein anderes kommen kann
    3. lastParts[c] = nil für alle c
  }
  for i:=1 to length(str) do begin
    {Schleifeninvarianten:
      1. result = teilfolgen[1..i-1]
      2. Ist last[i] = 0, dann ist lastParts[str[i]] = nil,
         ansonsten gab es einen Durchlauf mit i = last[i], und es gilt
         lastParts[str[i]] = teilfolgen[1..last[i]-1]
      3. 0 <= result[i] < BASE für alle i
    }
    c:=str[i];
    if lastParts[c]=nil then begin
      {$ifdef debug}
        form1.possibilities.lines.add(copy(str,1,i)+': & 2 * '+tostr(result)+'\\');
      {$endif}
      {Es gilt:
        last[i] = 0
      }
      SetLength(lastParts[c],numberLen);
      {Auswirkungen der nächsten Anweisung.
        lastPart'[c] := result = teilfolgen[1..i-1]

       Angenommen es gibt ein k mit last[k] = i, dann gilt:
         teilfolgen[1..last[k]-1] = teilfolgen[1..i-1] = lastPart'[c] = lastPart'[str[i]]
       Das heißt in diesem Durchlauf ist die zweite Schleifeninvariante erfüllt.
      }
      Move(result[0],lastParts[c][0],numberSize);

      {Auswirkungen der nächsten Anweisung.
        result' := result + result = 2*result, das heißt im nächsten Durchlauf
        ist die erste Schleifeninvariante erfüllt. (siehe Lösungsidee)

        Die Bedingungen für add sind erfüllt:
        1. length(result) = length(result)
        2. erfüllt nach dritter Schleifeninvariante
        3. erfüllt nach dritter Schleifeninvariante
      }
      add(result,result);
    end else begin
      {$ifdef debug}
        form1.possibilities.lines.add(copy(str,1,i)+': & 2 * '+tostr(result)+' - '+toStr(lastParts[c])+'\\');
        if i>100 then exit;
      {$endif}
      {Auswirkungen der nächsten Anweisung.
        oldPossibilities = lastParts[c] = teilfolgen[1..last[k]-1]
      }
      move(lastParts[c][0],oldPossibilities[0],numberSize);
      {Auswirkungen der nächsten Anweisung.
        lastPart'[c] = result = teilfolgen[1..i-1]

       Angenommen es gibt ein k mit last[k] = i, dann gilt:
         teilfolgen[1..last[k]-1] = teilfolgen[1..i-1] = lastPart'[c] = lastPart'[str[i]]
       Das heißt in diesem Durchlauf ist die zweite Schleifeninvariante erfüllt.
      }
      move(result[0],lastParts[c][0],numberSize);
      {Auswirkungen der nächsten beiden Anweisung.
        result' = result + result - oldPossibilities = 2*result - teilfolgen[1..last[k]-1],
        das heißt im nächsten Durchlauf ist die erste Schleifeninvariante erfüllt.
        (siehe Lösungsidee)

        Die Bedingungen für add sind erfüllt:
        1. length(result) = length(result)
        2. erfüllt nach dritter Schleifeninvariante
        3. erfüllt nach dritter Schleifeninvariante

        Die Bedingungen für sub sind erfüllt:
        1. length(result) = numberLen = length(oldPossibilities)
        2. erfüllt nach dritter Schleifeninvariante
        3. erfüllt nach dritter Schleifeninvariante
      }
      add(result,result);
      sub(result,oldPossibilities);
    end;
    if i mod 50=0 then Form1.ProgressBar1.Position:=i;
  end;
end;

//=========================Auflisten aller Teilfolgen===========================



procedure TForm1.listClick(Sender: TObject);
var start:string;     //Ausgangsfolge
    max:integer;      //Maximale Anzahl von Teilfolgen
    i,j:integer;      //Schleifenindizes
    sel: string;      //Aktuelle Teilfolge
    selSize: integer; //Länge der aktuellen Teilfolge
    sl:TStringList;   //Alle Teilfolgen
begin
  if not direct.Checked then //Keinen String aus der Datei laden
    raise Exception.create('String muss direkt eingegeben werden');
  start:=folge.text;
  if length(start)>31 then //Zu lang für 32-Bit Datentypen
    raise Exception.create('Folge zu lang');

  sl:=TStringList.create();

  max:=1 shl length(start) - 1;
  for i:=0 to max do begin
    //i durchläuft zwischen 000..000 bis 111..111, alle möglichen Werte
    //0 gibt an, dass der Wert an dieser Stelle nicht genommen werden soll
    //1 gibt an, dass der Wert zu sel hinzugefügt werden soll
    setlength(sel,length(start));
    selSize:=0;
    for j:=1 to length(start) do //Alle Bits durchlaufen
      if 1 shl (j-1) and i <> 0 then begin //Bit gesetzt
        inc(selSize);           //Verlängern
        sel[selSize]:=start[j]; //Zeichen eintragen
      end;
    setlength(sel,selSize);     //sel auf die tatsächliche Länge setzten
    sl.Add(sel);                //In die Liste einfügen
  end;

  //Teilfolgen alphabetisch sortieren
  sl.sort;

  //Ausgabe Memo Feld mit nur einer leer Zeile initialisieren
  possibilities.Clear;
  possibilities.Lines.BeginUpdate;
  possibilities.lines.add('');
  //Doppelte Teilfolgen aus sl herausfiltern
  for i:=1 to sl.Count-1 do
    if (sl[i]<>sl[i-1]) then //Ist der vorherige Strin ein anderer (erstes Auftreten)
      possibilities.lines.add(sl[i]); //dann kann sl[i] ausgegeben werden
  possibilities.Lines.EndUpdate;

  calculatedCount.text:='Es gibt '+inttostr(possibilities.lines.Count)+' Teilfolgen';
  sl.free;
end;






procedure TForm1.countClick(Sender: TObject);
var i:integer;
    s:string;
    f:file;
begin
  ProgressBar1.Visible:=true;
  if direct.Checked then
    s:=folge.text
  else begin
    AssignFile(f,folge.text);
    reset(f,1);
    SetLength(s,FileSize(f));
    BlockRead(f,s[1],filesize(f));
    CloseFile(f);

    for i:=length(s)downto 1 do
      if not (s[i] in ['A'..'Z','Ü','Ö','Ä','ß',#$A]) then begin
        ShowMessage('error: '+inttostr(i)+': '+s[i-1]+s[i]+s[i+1]);
        exit;
      end else if s[i]=#$A then delete(s,i,1);
    for i:=length(s)downto 1 do
      if not (s[i] in ['A'..'Z','Ü','Ö','Ä','ß']) then begin
        ShowMessage('error: '+inttostr(i)+': '+s[i-1]+s[i]+s[i+1]);
        exit;
      end;
  end;
  calculatedCount.text:='Es gibt '+ToStr(countParts(s))+' Teilfolgen';;//+' Teilfolgen';
  ProgressBar1.Visible:=false;
end;


procedure TForm1.directClick(Sender: TObject);
begin
  if direct.Checked then Title.Caption:='Folge der Übungen:'
  else Title.Caption:='Dateiname:';
end;

end.
                  //E:\programs\delphi\bwinf\24\2\2\verwandlung-big.txt
