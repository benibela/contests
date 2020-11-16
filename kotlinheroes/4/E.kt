import kotlin.math.absoluteValue
import kotlin.math.max
import kotlin.math.min


fun xmin(a: Int,b:Int) =
    if (a == -1) b
    else if (b == -1) a
    else min(a,b)

fun docase(nextLine: () -> String){
    val (n,m,k) = nextLine().split(" ").map { it.toInt() }
    val swap = (0 until m).map { nextLine().split(" ").map { it.toInt() } }

    val a = IntArray(n + 1) {-1}
    a[k] = 0

    swap.forEach {
        val (x,y) = it
        val ax = a[x]
        val ay = a[y]
        //swap
        a[x] = ay
        a[y] = ax
        //fake swap
        if (ax != -1)
            a[x] = xmin(a[x], ax + 1)
        if (ay != -1)
            a[y] = xmin(a[y], ay + 1)
    }

        (1 until (n+1)).forEach { i ->
            if (i != 1) print(" ${a[i]}");
            else print(a[i])
        }
        println()


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
3
4 5 1
3 4
2 1
4 1
3 1
3 1
5 7 4
3 2
3 2
4 2
3 4
4 1
3 2
5 2
7 15 5
5 3
4 2
6 1
2 4
1 6
3 7
5 6
4 2
6 4
2 6
6 3
6 3
7 6
2 6
7 2


""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}





