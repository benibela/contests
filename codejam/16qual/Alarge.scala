
def f(missing: Seq[Int], N: Long, baseN: Long): Long = {
  val Nsplit = N.toString.split("").map(i=>i.toInt);
  val missing2 = missing.filter(i=> !Nsplit.contains(i));
  if (missing2.length == 0) N
  else f(missing2, N + baseN, baseN)
};
declare function g($N){
  if ($N eq 0) then "INSOMNIA"
  else f(0 to 9, $N, $N)
};
for $n at $i in tail(tokenize($raw, $line-ending))[normalize-space()] return
  concat("Case #", $i, ": ", g($n))


def solveA(fn: String) {
  var it = io.Source.fromFile("/tmp/"+fn+".in").getLines.filter(_ != "")
  val pw = new java.io.PrintWriter(new java.io.File("/tmp/"+fn+".out"))
  val T = it.next
  for (i <- 1 to T.toInt) {
    val N = it.next.toInt;
    if (N) pw.println("Case #"+i+": YES")
    else pw.println("Case #"+i+": NO")
  }
 
  pw.close
}