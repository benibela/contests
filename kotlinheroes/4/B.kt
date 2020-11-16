import kotlin.math.absoluteValue
import kotlin.math.min

//Kotlin Heros  2

fun docase(nextLine: () -> String){
    val (n,k1i,k2) = nextLine().split(" ").map { it.toLong() }
    val ed = nextLine()

    val k1 = min(k1i, k2)

    var lastDay = 0L
    var total = 0L
    (0 until n.toInt()).forEach { i ->
        val d = if (ed[i] == '0') 0 else min(k2 - lastDay, k1)
        total += d
        lastDay = d
    }

    println(total);
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
4
4 5 7
1011
4 4 10
0101
5 3 4
11011
6 4 6
011101
""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}

