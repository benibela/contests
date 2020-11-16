import kotlin.math.absoluteValue
import kotlin.math.min

//Kotlin Heros  C

fun docase(nextLine: () -> String){
    val (n,k,x,y) = nextLine().split(" ").map { it.toLong() }
    val a = nextLine().split(" ").map { it.toLong() }.sortedDescending()

    var best = x * n


    var total = a.sum()
    val maxallowed = n * k

    if (total <= maxallowed) best = min(best, y)

    if (a[0] <= k) best = 0
    else {
        (0 until n.toInt()).map { i ->
            var newbest = x * (i + 1L)
            if ( i + 1 < a.size ) {
                if (a[i+1] <= k) best = min(best, newbest)
                total -= a[i]
                if (total <= maxallowed) best = min(best, newbest + y)
            }
        }
    }

    println(best);
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
6
5 4 3 5
1 2 2 3 5
5 3 4 5
1 5 1 5 5
5 4 5 6
1 2 5 3 5
4 3 2 10
4 4 1 1
4 3 10 2
4 4 1 1
4 1 5 4
1 2 1 3
""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}



