import kotlin.math.absoluteValue

fun docase(nextLine: () -> String){
    val start = nextLine().split(" ").map { it.trim() }
    var x = start[0].toInt()
    var y = start[1].toInt()
    val path = start[2]

    var bestMeetup = Int.MAX_VALUE
    var t = 0
    path.forEach { dir ->
        var nx: Int = x
        var ny: Int = y
        when (dir) {
            'W' -> nx = x - 1
            'E' -> nx = x + 1
            'N' -> ny = y + 1
            'S' -> ny = y - 1
        }


        x = nx
        y = ny
        t = t+ 1

        val mint = x.absoluteValue + y.absoluteValue
        if (mint <= t && t < bestMeetup) bestMeetup = t
    }

    if (bestMeetup == Int.MAX_VALUE)
        println("IMPOSSIBLE")
    else
        println ( bestMeetup )

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
7
3 2 SSSW
4 0 NESW
4 4 SSSS
3 0 SNSS
2 10 NSNNSN
0 1 S
2 7 SSSSSSSS



""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}

