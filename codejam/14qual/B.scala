
import scala.collection._;


import scala.language.postfixOps;

import mutable.WrappedArray;
import mutable.ArrayBuffer

import scala.language.implicitConversions

import scala.io._;

object B {

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

      val c = in().toDouble;
      val f = in().toDouble;
      val x = in().toDouble;

      var res = x / 2.0;
      var nres = x / 2.0;
      var farmcost = 0.0;
      var i = 0;
      var b = false;
      while (!b) {
        farmcost += c / (2 + i * f);
        nres = farmcost + x / (2 + i * f + f);
        if (nres < res ) res = nres;
        else b = true;
        i += 1;
      }


      val xxx = "Case #" + t + ": " + res;
      pw.println(xxx)
      if (t < 10) println(xxx)
    }
    if (T >= 10) println("..");
    pw.close
  }
}