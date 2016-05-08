/*
import scala.collection._;
import scala.language.postfixOps;

import mutable.WrappedArray;
import mutable.ArrayBuffer

import scala.language.implicitConversions

import  scala.io._;*/

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
  
  def bf(max: Int, plates: Array[Int]): Int = {    
    var best = max;
    if (max  > 2) {
      var preMax = 0
      for (j <- 1 until max) if (plates(j)!=0) preMax = j;
      val old = plates(max)
      plates(max) = 0
      for (i <- 1 to max/2) {
        plates(i) += old
        plates(max - i) += old
        best = Math.min(best, bf(Math.max(preMax, Math.max(max -i,i)), plates) + old) 
        plates(i) -= old
        plates(max - i) -= old
      }
      plates(max) = old
    /*var preMax = 0;
    for (j <- 1 until max) if (plates(j)!=0) preMax = j;
    val old = plates(max);
    plates(max) = 0;
    plates((max+1)/2) += old
    plates((max)/2) += old
    val bestSplit = old + bf(Math.max(preMax,(max+1)/2), plates);
    plates(max) = old;
    plates((max+1)/2) -= old
    plates((max)/2) -= old
    
    best = Math.min(best, bestSplit);*/

    }
    best 
  }
  
  var cas = "";
  def bf2(l: List[Int]): Int = {
    var best = 0;
    for (i <- l) best = Math.max(best, i);
    val maxi = l.indexOf(best)
    for (i <- 0 until l.length) 
      if (l(i) > 3 && i == maxi) { 
        best = Math.min(best, 1 + bf2((l(i) / 2) +: ((l(i)+1) / 2 ) +: (l.take(i) ++ l.drop(i+1))));
        val ob = best;
        best = Math.min(best, 2 + bf2((l(i) / 3) +: ((l(i) + 1) / 3) +: ((l(i)+2) / 3 ) +: (l.take(i) ++ l.drop(i+1))))
        if (best < ob) println(cas + " | "+l.mkString(" ")+ ": "+l(i)+": tripple");
      }
    best
  }

  def solve(fn: String) {
    val in = In(io.Source.fromFile("/tmp/" + fn + ".in"))
    //val pw = java.lang.System.out; //
    val pw = new java.io.PrintWriter(new java.io.File("/tmp/" + fn + ".out"))
    val T = in().toInt;
    for (t <- 1 to T) {

      val D = in().toInt;
/*      val tc = in(D).toList;
      cas =  "Case #" + t + ": " + tc.mkString(" ");
      val res = bf2(tc.map(_.toInt))*/
      val plates = Array.fill(1001)(0);
      val nextMax = Array.fill(1001)(0);
      var max = 0;
      for (i <- 1 to D) {
        val cur = in().toInt;
        plates(cur) += 1;    
        if (cur > max) max = cur;
      }
      /*println("init: "+ max + ": "+plates.take(max+1).mkString(" "));
      var changed = true; 
      var totalSplitCount = 0;
      while (changed) {
        changed = false;
        var lastNonZero = 0;
        for (i <- 0 to max) {
          nextMax(i) = lastNonZero;
          if (plates(i) != 0) lastNonZero = i;
        }
        val noSplit = max
        var i = max;
        var splitCount = 0;        
        while (i >= 0 && splitCount + plates(i) + Math.max((max+1)/2, nextMax(i)) >= noSplit ) {
          splitCount += plates(i);
          i -= 1;
        }
        if (i >= 0) {
          splitCount += plates(i);
          println("split: "+ i + " with "+splitCount );
          totalSplitCount += splitCount;
          changed = true;
          for (j <- i to max) {
            plates((j+1)/2) += plates(j) 
            plates(j/2) += plates(j) 
          }
          max = Math.max(nextMax(i), (max+1)/2);
         println("      "+ max + ": "+plates.take(max+1).mkString(" "));
        }
      }
      val res = totalSplitCount + max;*/
      val res = bf(max, plates)

      val xxx = "Case #" + t + ": " + res;
      pw.println(xxx)
      if (t < 10) println(xxx)
    }
    if (T >= 10) println("..");
    pw.close
  }
}
