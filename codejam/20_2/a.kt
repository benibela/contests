import kotlin.math.absoluteValue
//2.1
 

val ZERO = 0.toBigInteger()

fun sum(a: Long) = (a.toBigInteger() * (a + 1).toBigInteger()).shiftRight(1)

//sum of i + ... (i+2(k-1))
fun sumEven(i: Long, k: Long) =
    if (k == 0L) ZERO
    else
      (i + k - 1).toBigInteger() * (k).toBigInteger()

    /*
fun docaseCORRECTsmall(ain: Long,bin: Long):Triple<Long,Long,Long>{

    var a = ain
    var b = bin
    var totalCustomers: Long = 0L

    var nextCustomer: Long = totalCustomers + 1L
    while ( a >= nextCustomer || b >= nextCustomer ) {
        if (a >= b) a -= nextCustomer;
        else b -= nextCustomer

        nextCustomer++;
        totalCustomers++;
    }


    return Triple(totalCustomers, a, b)

}
      */


fun docaseX(start: List<Long>){
    var a = start[0].toLong()
    var b = start[1].toLong()
    //val (refTC, refA, refB) = docaseCORRECTsmall(a,b    )

    var swapped = if (a > b) {
        val c = b
        b = a
        a = c
        true
    } else false

    //assert a <= b

    var abig = a.toBigInteger()
    var bbig = b.toBigInteger()

    var mi = 0L
    var ma = b

    while (mi < ma) {
        val middle = mi + (ma - mi) / 2
        val s = sum(middle)
        if (bbig - s > abig) mi = middle + 1
        else ma = middle
    }

    var bigstackCustomers = mi

    if (b - sum(bigstackCustomers).toLong() < a) bigstackCustomers --

    b = b - sum(bigstackCustomers).toLong()

    if (swapped) {
        val c = b
        b = a
        a = c
    }

    if (b > a && b >= bigstackCustomers + 1){
        bigstackCustomers++
        b -= bigstackCustomers
    }
    //assert a >= b

    abig = a.toBigInteger()
    bbig = b.toBigInteger()

    mi = 0L
    ma = b

    while (mi < ma) {
        val middle = mi + (ma - mi) / 2
        val sa = sumEven(bigstackCustomers + 1, middle)
        val sb = sumEven(bigstackCustomers + 2, middle)
        if (sa < abig || sb < bbig) mi = middle + 1
        else ma = middle
    }

    //println("$mi")

    var altCust = mi
    while ( altCust > 0 ) {
        val sa = sumEven(bigstackCustomers + 1, altCust).toLong()
        val sb = sumEven(bigstackCustomers + 2, altCust).toLong()
        if (a < sa || b < sb)
          altCust --;
        else
            break;

    }

    var totalCustomers: Long = bigstackCustomers + altCust*2

    a = a - sumEven(bigstackCustomers + 1, altCust).toLong()
    b = b - sumEven(bigstackCustomers + 2, altCust).toLong()

   // println("$altCust $a $b")

    var nextCustomer: Long = totalCustomers + 1L
    while ( a >= nextCustomer || b >= nextCustomer ) {
        if (a >= b) a -= nextCustomer;
        else b -= nextCustomer

        nextCustomer++;
        totalCustomers++;
    }


    //if (totalCustomers != refTC || a != refA || b != refB) {
      //  println(start)
        println("$totalCustomers $a $b")
    //}

}

fun docase(nextLine: () -> String) {
    val start = nextLine().split(" ").map { it.trim().toLong() }
    docaseX(start)
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

(0..100).map { a ->

    (0..100).map { b ->

        docaseX(listOf(a.toLong(), b.toLong()))
    }
}

val contestdata = """
11
0 2
0 3
2 0
3 0
4 0
1000 10
1000 20
1000 30
1000 500
10 1000
20 1000
30 1000
60 1000
1 2
2 2
8 11
1000 1
1 1000
1 0
1000 1050
1000 1060
1000 1080
1000 1100
1050 1000
1060 1000
1080 1000
1100 1000
""".trim().trimIndent().split("\n")

var line = 0
docontest {
    val res = contestdata.getOrNull(line) ?: ""
    line += 1
    res
}

println()