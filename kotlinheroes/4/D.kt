import kotlin.math.absoluteValue
import kotlin.math.max
import kotlin.math.min


fun docase(nextLine: () -> String){
    val (n,m) = nextLine().split(" ").map { it.toInt() }
    val tun = (0 until m).map { nextLine().split(" ").map { it.toInt() } }

    val a = IntArray(n + 1) {0}

    tun.forEach {
        val (u,v,w) = it
        a[u] = max(a[u], w)
        a[v] = max(a[v], w)
    }

    var fail = false
    tun.forEach {
        val (u,v,w) = it
        if (w != min(a[u], a[v])) fail = true
    }

    if (fail) println("NO");
    else{
        println("YES")
        (1 until (n+1)).forEach { i ->
            if (i != 1) print(" ${a[i]}");
            else print(a[i])
        }
        println()
    }


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
3 2
1 2 1
2 3 1
5 7
3 2 7
3 4 9
1 5 5
1 2 5
4 1 5
4 2 7
3 1 5
4 4
1 2 5
3 2 2
4 1 3
3 4 4""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}





