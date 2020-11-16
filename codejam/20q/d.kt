
import java.io.BufferedReader

fun String.toInts() = this.split(" ").map { it.toInt() }

inline fun debug(s: String){
    //System.err.println(s)
}

fun main(args: Array<String>){
    val bf = System.`in`.bufferedReader()

    val x = bf.readLine().toInts()
    val t = x[0]
    val b = x[1]

    var reads = intArrayOf(1,2,3)
    var qc = 0


    fun invert(){
        debug("invert")
        (0 until b).forEach{reads[it] = 1 - reads[it]}
    }
    fun flip(){
        debug("flip")
        (0 until (b/2)).forEach{
            val t = reads[it]
            reads[it] = reads[b - 1 - it]
            reads[b - 1 - it] = t
        }
    }

    fun query(i: Int): Int = run {
        assert(i >= 0)
        assert(i < b)
        qc ++;
        println(i + 1)
        System.out.flush()
        val r = bf.readLine().toInt()
        //reads[i] = r
        r
    }

    (0 until t).forEach {
        reads = IntArray(b, {-1})
/*
        var p1 = -1
        var p2 = -1
        (0 until (b/2)).forEach {
            val l = query(it)
            val r = query(b - 1 - it)
            if (l != r)
                if (p1 == -1) p1 = it
                else if (p2 == -1) p2 = it
        }
                                                    */
        qc = 0
        var eq = -1
        var ne = -1
        (0 until (b/2)).forEach {
            val l = query(it)
            reads[it] = l
            val r = query(b - 1 - it)
            reads[b-it-1] = r
            if (l != r && ne == -1) ne = it;
            else if (l == r && eq == -1) eq = it;
            debug("$qc")
            val quantum = qc.rem(10) == 0
            if (quantum) {
                debug("$qc: $ne $eq")
                if (ne == -1) {
                    if (query(0) != reads[0]) invert();
                    query(0)
                } else if (eq == -1) {
                    if (query(0) != reads[0]) invert();
                    query(0)
                } else {
                    if (query(eq) != reads[eq]) invert();
                    if (query(ne) != reads[ne]) flip();
                }
            }
        }
        

        println(reads.joinToString(""));
        System.err.println(bf.readLine())

    }
}
    /*var lines: Int = 0
    val bf = System.`in`.bufferedReader(Charsets.ISO_8859_1)
    println(bf.readLine());
    bf.skip(1)
    println(bf.readLine());
    bf.skip(1)
    println(bf.readLine());
    bf.skip(1)
    return

    while (bf.readLine() != null) {
        lines++
        bf.skip(1)
        
    }

//    lines = bf.lines().count().toInt()

    //return


    //while (readLine() != null) lines++;
    println(lines)
}*/