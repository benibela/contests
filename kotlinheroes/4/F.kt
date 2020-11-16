import kotlin.math.abs
import kotlin.math.absoluteValue
import kotlin.math.max
import kotlin.math.min


fun singledim(ain: LongArray, upi: List<Int>, upd: LongArray): LongArray {
    val best = LongArray(upi.size + 1)   { Long.MAX_VALUE }
    val a = ain.clone()
    a.indices.forEach { x ->
        ain.indices.forEach { a[it] = ain[it] }
        var s: Long = a.indices.map { i ->
            abs( i - x).toLong() * a[i]
        }.sum()
        if (s < best[0]) best[0] = s

        upi.forEachIndexed { index, i ->
            val d = upd[index]
            a[i] += d
            s += abs( i - x).toLong() * d
            //s += abs( i - x).toLong() * newa
            if (s < best[index + 1]) best[index + 1] = s
        }
    }
    return best
}

fun docase(nextLine: () -> String){
    val (n,m,q) = nextLine().split(" ").map { it.toInt() }
    val a = (0 until n).map { nextLine().split(" ").map { it.toLong() }.toLongArray() }
    val updates = (0 until q).map { val r = nextLine().split(" ").map { it.toInt() }
        Triple(r[0] - 1, r[1] - 1, r[2])
    }

    val ax = LongArray(n) { a[it].sum() }
    val ay = LongArray(m) { u -> (0 until n).asSequence().map { v -> a[v][u] }.sum() }


    val upx = updates.map { it.first }
    val upy = updates.map { it.second }

    val updelta = LongArray(updates.size) { 0 }
    //val updeltay = IntArray(updates.size) { 0 }

    updates.forEachIndexed { i, up ->
        val (x, y, v) = up
        val olda = a[x][y]
        a[x][y] = v.toLong()

        updelta[i] = a[x][y] - olda
        //updeltay[i] = a[x][y] - olda
    }

    val bestx = singledim(ax, upx, updelta)
    val besty = singledim(ay, upy, updelta)


    val best = bestx.mapIndexed { i, it -> it + besty[i]}
    println(best.joinToString(" ") )
}

fun docontest(nextLine: () -> String) {
    val N = nextLine().toInt()
    (1..N).map {case ->
        docase(nextLine)
    }
}

fun main(args: Array<String>) {
    val bf = System.`in`.bufferedReader()
    docontest {
        bf.readLine() ?: ""
    }


}



val contestdata = """
2
3 3 1
1 2 3
2 1 2
1 1 2
2 3 100
4 4 3
2 5 6 3
4 8 10 5
2 6 7 1
8 4 2 1
1 1 8
2 3 4
4 4 5

""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}





