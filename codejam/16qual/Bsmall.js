/*
 * This is a JavaScript Scratchpad.
 *
 * Enter some JavaScript, then Right Click or choose from the Execute Menu:
 * 1. Run to evaluate the selected text (Ctrl+R),
 * 2. Inspect to bring up an Object Inspector on the result (Ctrl+I), or,
 * 3. Display to insert the result in a comment after the selection. (Ctrl+L)
 */
 
function solve(s){
  var p = s.lastIndexOf(0);
  if (p < 0) return 0;
  var t = s.slice(0, p);
  for (var i=0;i<t.length;i++) t[i] = 1 - t[i];
  return 1 + solve(t);
}
function solves(s){
  var a = [];
  for (var i=0;i<s.length;i++) 
      if (s[i] == '-') a.push(0); 
      else if (s[i] == '+') a.push(1);
  return solve(a);
}
//document.body.innerHTML = "<textarea>";
var ta = document.getElementsByTagName("textarea")[0];

var inp = ta.value.split("\n");
var res = [];
for (var e=inp[0]*1, i=1; i <= e; i++) 
  res.push("Case #"+i+": "+ solves(inp[i]));
ta.value=(res.join("\n"))
