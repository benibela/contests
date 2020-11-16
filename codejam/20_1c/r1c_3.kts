import kotlin.math.absoluteValue


fun doit(n: Long, d: Long, a: LongArray): Long{
    val counts: MutableMap<Long,Long> = mutableMapOf<Long,Long>()
    a.forEach { counts[it] = (counts[it] ?: 0) + 1 }

    a.forEach {
        if (counts[it] ?: 0 >= d) return 0
    }

    a.forEach {
        if (counts.contains(2*it) ) return 1
    }

    a.forEach {
        if (counts[it] ?: 0 >= 2 ) {
            if (it != a.last()) return 1
        }
    }

    return d - 1
}

fun docase(nextLine: () -> String){
    val start = nextLine().split(" ").map { it.trim() }
    var n = start[0].toLong()
    var d = start[1].toLong()
    val a = nextLine().split(" ").map { it.toLong() }.sorted()

    println(doit(n,d,a.toLongArray()))
}

fun docontest(nextLine: () -> String) {
    val N = nextLine().toInt()
    (1..N).map {case ->
        print("Case #$case: ")
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
1 3
1
5 2
10 5 359999999999 123456789 10
2 3
8 4
3 2
1 2 3
""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}

