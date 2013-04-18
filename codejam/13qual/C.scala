def find(len: Int) = {
  if (len < 1) ArrayBuffer.empty[BigInt]
  else if (len == 1) ArrayBuffer[BigInt](1,2,3)
  else {
  val tenPowers = (0 to len) map (i=>BigInt(10).pow(i))
  val paliPowers = (0 to len/2) map (i => tenPowers(i) + (if (i != len-1-i) tenPowers(len-1-i) else 0 ))
  var res = ArrayBuffer.empty[BigInt]
  var cur = BigInt(0);
  def enum(p: Int){
    if (p == (len+1)/2) {
      res += cur
    } else {
      enum(p+1)
      cur += paliPowers(p);
      val sqr = (cur*cur).toString;
      if (sqr == sqr.reverse) {
        enum(p+1)
        if (2*p+1 == len) {
         cur += paliPowers(p);
         val sqr = (cur*cur).toString;
         if (sqr == sqr.reverse) enum(p+1)
         cur -= paliPowers(p);
        }
      }
      cur -= paliPowers(p);
    }
  }
  cur += (paliPowers(0));
  enum(1)
  cur += (paliPowers(0));
  enum(1)
  res
  }
}

scala> val all = (0 to 51) flatMap find
all: scala.collection.immutable.IndexedSeq[BigInt] = Vector(1, 2, 3, 11, 22, 101, 111, 121, 202, 212, 1001, 1111, 2002, 10001, 10101, 10201, 11011, 11111, 11211, 20002, 20102, 100001, 101101, 110011, 111111, 200002, 1000001, 1001001, 1002001, 1010101, 1011101, 1012101, 1100011, 1101011, 1102011, 1110111, 1111111, 2000002, 2001002, 10000001, 10011001, 10100101, 10111101, 11000011, 11011011, 11100111, 11111111, 20000002, 100000001, 100010001, 100020001, 100101001, 100111001, 100121001, 101000101, 101010101, 101020101, 101101101, 101111101, 110000011, 110010011, 110020011, 110101011, 110111011, 111000111, 111010111, 111101111, 111111111, 200000002, 200010002, 1000000001, 1000110001, 1001001001, 1001111001, 1010000101, 1010110101, 1011001101, 1011111101, 1100000011, 1100110011, 1101001011, ...

scala> val all2 = (all map (i=>i*i)) sorted

def solveC(fn: String) {
  var it = io.Source.fromFile("/tmp/"+fn).getLines.filter(_ != "")
  //val pw = java.lang.System.out; //
  val pw = new java.io.PrintWriter(new java.io.File("/tmp/"+fn+".out"))
  val T = it.next.toInt;
  for (t <- 1 to T) {
    val r = it.next.split(" ");
    val A = BigInt(r(0)); val B = BigInt(r(1));
    pw.println("Case #"+t+": "+all2.view.filter(x => A <= x && x <= B).length)
  }
  pw.close
}