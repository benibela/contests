
def solveB(fn: String) {
  var it = io.Source.fromFile("/tmp/"+fn).getLines.filter(_ != "")
  //val pw = java.lang.System.out; //
  val pw = new java.io.PrintWriter(new java.io.File("/tmp/"+fn+".out"))
  val T = it.next
  for (i <- 1 to T.toInt) {
    val temp = it.next.split(" ").map(_.toInt);
    val N = temp(0); val M = temp(1)
    val sq = it.take(N).flatMap(_.split(" ").map(_.toInt)).toArray
    val board = Table[Int](N,M,sq)
    val lawnRows = board.rows.map(_.max).toArray
    val lawnCols = board.cols.map(_.max).toArray
    var possible = true;
    board.foreach((row, col, height) => { possible = possible && height == min(lawnRows(row), lawnCols(col))}  )
    if (possible) pw.println("Case #"+i+": YES")
    else pw.println("Case #"+i+": NO")
  }
 
  pw.close
}