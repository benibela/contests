import kotlin.math.absoluteValue

//Kotlin Heros

fun docase(nextLine: () -> String){
    val (n,k) = nextLine().split(" ").map { it.toLong() }

    val f = 1 + k + k*k + k * k*k;
    val b = n / f

    println("$b ${b*k} ${b*k*k} ${b*k*k*k}");
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
40 3
1200 7
320802005 400
4 1
""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}

