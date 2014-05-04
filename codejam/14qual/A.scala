
import scala.collection._;








import scala.language.postfixOps;

import mutable.WrappedArray;
import mutable.ArrayBuffer

import scala.language.implicitConversions

import  scala.io._;

object A {

  //TokenIterator and In stolen from winger's submission to GCJ13 qualification round
  class TokenIterator(iter: BufferedIterator[Char], delims: String) extends Iterator[String] {
    private val sb = new StringBuilder

    def hasNext: Boolean = {
      skipDelims()
      iter.hasNext
    }

    def skipDelims() {
      while (iter.hasNext && delims.indexOf(iter.head) != -1) {
        iter.next()
      }
    }

    def next(): String = {
      skipDelims()
      while (iter.hasNext && delims.indexOf(iter.head) == -1) {
        sb.append(iter.next())
      }
      val ret = sb.toString()
      sb.clear()
      ret
    }
  }

  case class In(source: Source) {
    val iter = source.buffered

    val tokenIterator = new TokenIterator(iter, " \r\n")

    val lineIterator = new TokenIterator(iter, "\r\n")

    def apply() = tokenIterator.next()

    def apply(n: Int) = tokenIterator.take(n)
  }




  def solve(fn: String) {
    val in = In(io.Source.fromFile("/tmp/" + fn + ".in"))
    //val pw = java.lang.System.out; //
    val pw = new java.io.PrintWriter(new java.io.File("/tmp/" + fn + ".out"))
    val T = in().toInt;
    for (t <- 1 to T) {



      val r1 = in().toInt;
      val t1 = (0 to 3) map (i => in(4).map(_.toInt).toSet);

      val r2 = in().toInt;
      val t2 = (0 to 3) map (i => in(4).map(_.toInt).toSet);

      val c = t1(r1-1).intersect(t2(r2-1));

      val res = if (c.size == 0) "Volunteer cheated!" else if (c.size == 1) c.toList(0) else "Bad magician!";


      val xxx = "Case #" + t + ": " + res;
      pw.println(xxx)
      if (t < 10) println(xxx)
    }
    if (T >= 10) println("..");
    pw.close
  }
}