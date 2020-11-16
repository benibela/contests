import kotlin.math.absoluteValue

//2.2

fun gcd(a: Int, b: Int) = kotlin.run {
    var n1 = if (a > 0) a else -a
    var n2 = if (b > 0) b else -b

    while (n1 != n2) {
        if (n1 > n2)
            n1 -= n2
        else
            n2 -= n1
    }
    n1
}

var coords: Array<IntArray>
var coorddirs: Array< Array<IntArray>>
var coorddistances: Array< LongArray >

var linked: IntArray
var entered: BooleanArray
var dir: IntArray

fun visitout(pos: Int, ): Int {
    val n = linked.size
    val cpoos = coords[pos]
    (0 until n).forEach { i->
        if (i != pos) {
            val d = coorddirs[pos][i]
            if (d[0] == dir[0] && d[1] == dir[1]) {
                
            }
            val toIx = coords[i][0] - cpoos[0]
            val toIy = coords[i][1]- cpoos[1]
            coords[i]
        }
    }
}

fun visitin(pos: Int): Int {
    val n = linked.size
    var visited = 0
    if (linked[pos] >= 0) {
        return if (entered[pos]) 0 else {
            entered[pos] = true
            val temp = visitout(linked[pos], coords, linked, entered, dir)
            entered[pos] = false
            temp
        }
    }

    visited = 1
    ( 0 until n).forEach {
        i ->
        if (linked[i] == -1) {

        }
    }
}


fun doit(n: Int, lcoords: Array<IntArray>): Int{
    var best = 3
    linked = IntArray(n)
    entered = BooleanArray(n)
    dir = IntArray(2)
    coords = lcoords
    coorddirs = coords.map { from -> coords.map { to ->
        val dx = to[0] - from[0]
        val dy = to[1] - from[1]
        val g: Int = gcd(dx, dy)
        intArrayOf( dx / g, dy / g )
    }.toTypedArray() }.toTypedArray()
    coorddistances = coords.map { from -> coords.map { to ->
        val dx = to[0] - from[0]
        val dy = to[1] - from[1]
        dx.toLong() * dx + dy.toLong() * dy
    }.toLongArray() }.toTypedArray()
    (0 until n).map { start ->
        (0 until n).map {second ->
            if (start != second)
                (0 until n).map {third ->
                    if (start != third && second != third) {
                        for (i in (0 until n)) {
                            linked[i] = -1;
                            entered[i] = false;
                        }
                        linked[start] = second;
                        linked[second] = start;
                        entered[start] = true;
                        dir = coorddirs[second][third]
                        val gcd = dir[0].toBigInteger().gcd(dir[1].toBigInteger()).toInt()
                        val nb = 2 + visitout(second)
                        if (nb > best) best = nb
                    }
                }
        }
    }
        return best
}

fun docase(nextLine: () -> String){
    val n = nextLine().trim().toInt()
    val coords = (0 until n).map { nextLine() }.map { it.split(" ").map { it.toInt() }.toIntArray() }.toTypedArray()

    if (n <= 3) println(n)
    else
      println(doit(n,coords))
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

