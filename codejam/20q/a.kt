fun domatrix(a: Array<IntArray>) {
    val n = a.size
    val trace = (0 until n).map { a[it][it] }.sum()
    val repcol = (0 until n).filter { col ->
        a[col].distinct().size != a[col].size
    }.size
    val reprows = (0 until n).filter { row ->
        val block = (0 until n).map { a[it][row] }
        block.distinct().size != block.size
    }.size
    println("$trace $repcol $reprows")
}

fun docase(nextLine: () -> String){
    val n = nextLine().toInt()
    val matrix = (0 until n).map {
        nextLine().split(" ").map { it.toInt() }.toIntArray()
    }.toTypedArray()
    domatrix(matrix)
}

fun docontest(nextLine: () -> String) {
    val N = nextLine().toInt()
    (1..N).map {case ->
        print("Case #$case: ")
        docase(nextLine)
    }
}

fun main(args: Array<String>) {
    val trialRun = true

    if (!trialRun) docontest { readLine() ?: "" }
    else {

        val contestdata = """
        3
        4
        1 2 3 4
        2 1 4 3
        3 4 1 2
        4 3 2 1
        4
        2 2 2 2
        2 3 2 3
        2 2 2 3
        2 2 2 2
        3
        2 1 3
        1 3 2
        1 2 3
        """.trimIndent().split("\n")

        var line = 0
        docontest {
            val res = contestdata.getOrNull(line) ?: ""
            line += 1
            res
        }
    }
}