unit utils;

interface
uses sysutils;
const DIGIT=['0'..'9'];
//Liest die nächste Tahl in str nach pos, und gibt das erste Zeichen hinter der
//Zahl zurück, und die Zahl selbeer
function readNumber(const str:string;var pos:integer):integer;
implementation
function readNumber(const str:string;var pos:integer):integer;
var start:integer;
begin
  //Erste Ziffer suchen
  while (pos<=length(str))and
       not  (str[pos] in DIGIT) do inc(pos);
  start:=pos; //Ziffer gefunden
  while (pos<=length(str))and //Zeichen, das keine Ziffer ist suchen
       (str[pos] in DIGIT) do inc(pos);
  //ausschneiden und in Zahl umwandeln
  result:=strtoint(copy(str,start,pos-start));
end;

end.
    