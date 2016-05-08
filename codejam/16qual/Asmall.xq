

declare function f($missing, $N, $baseN){
  let $Nsplit := string-to-codepoints(string($N)) ! (. - 48)
  let $missing2 := $missing [ not (. = $Nsplit) ] 
  return if (empty($missing2)) then $N
  else f($missing2, $N + $baseN, $baseN)
};
declare function g($N){
  if ($N eq 0) then "INSOMNIA"
  else f(0 to 9, $N, $N)
};
for $n at $i in tail(tokenize($raw, $line-ending))[normalize-space()] return
  concat("Case #", $i, ": ", g($n))
