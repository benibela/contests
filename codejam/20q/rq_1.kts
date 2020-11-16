
val open = (0 until 10).map { "(".repeat(it) }
val close = (0 until 10).map { ")".repeat(it) }

fun docase(nextLine: () -> String){

    val line = nextLine().trim()
    var nesting = 0
    val r = line.map { c ->
        val target = c.toInt() - '0'.toInt()
        val parens = if (target > nesting) open[target - nesting]
        else close[nesting - target]
        nesting = target
        parens + c
    }.joinToString("", postfix = close[nesting])

    println(r)
}

fun docontest(nextLine: () -> String) {
    val N = nextLine().toInt()
    (1..N).map {case ->
        print("Case #$case: ")
        docase(nextLine)
    }
}

fun main(args: Array<String>) {
    docontest { readLine() ?: "" }


}



val contestdata = """
5
0000
101
111000
1
312
""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}

