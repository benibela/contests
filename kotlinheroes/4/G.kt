import kotlin.math.abs
import kotlin.math.absoluteValue
import kotlin.math.max
import kotlin.math.min

fun subcase(start: Int, bigperiod: Int, periods: List<Int>, x: List<Int>): Boolean = run{
     periods.filter { bigperiod % it == 0 }.forEach { period ->
        val remainingX = x.filter { it -> ((it - start) % period) != 0 }
        when (remainingX.size) {
            0 -> {
                println("YES")
                println("$start $period")
                println("$start $period")
                return true
            }
            1 -> {
                println("YES")
                val start2 = remainingX[0]
                println("$start $period")
                println("$start2 $period")
                return true
            }
            else -> {
                val start2 = remainingX[0]
                val bigperiod2 = remainingX[1] - start2
                periods.filter { bigperiod2 % it == 0 }.forEach{ period2 ->
                    val remainingXX =  remainingX.filter { it -> ((it - start2) % period2) != 0 }
                    if (remainingXX.isEmpty()) {
                        println("YES")
                        println("$start $period")
                        println("$start2 $period2")
                        return true
                    } else false
                }
            }
        }
    }
    false
}

fun docase(nextLine: () -> String){
    val (k,n) = nextLine().split(" ").map { it.toInt() }
    val periods = nextLine().split(" ").map { it.toInt() } //k
    val x = nextLine().split(" ").map { it.toInt() } //n

    if ( n == 2 ){
        println("YES")
        println("${x[0]} ${periods[0]}")
        println("${x[1]} ${periods[0]}")
        return
    }

    subcase(x[0], x[1] - x[0], periods, x ) ||
            subcase(x[0], x[2] - x[0], periods, x ) ||
            subcase(x[1], x[2] - x[1], periods, x ) || run{
        println("NO")
        true
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
5
3 5
3 5 7
1 4 5 7 12
3 2
1 2 3
1 10
3 4
1 2 3
5 7 9 11
3 4
10 20 100
2 3 4 7
3 6
4 6 7
0 12 18 24 100 107


""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}





