(:xidel - --xquery ':)
  for $T at $t in tokenize($raw, $line-ending)[contains(., " ")] 
  return x"Case #{$t}: {
    (add := 0, there := 0)[0], 
    for $count at $s in string-to-codepoints(substring-after($T, " ")) ! (. - 48) 
    return (
           if ($s - 1 > $there and $count > 0) then ($delta := ($s - 1) - $there, $there := $there + $delta + $count, $add := $add + $delta)       
           else $there := $there + $count)[0],    
    $add
  }"
(:' < in > out :)
