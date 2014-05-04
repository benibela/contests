
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

  class In(source: io.Source) {
    val iter = io.source.buffered

    val tokenIterator = new TokenIterator(iter, " \r\n")

    val lineIterator = new TokenIterator(iter, "\r\n")

    def apply() = tokenIterator.next()

    def apply(n: Int) = tokenIterator.take(n)
  }


