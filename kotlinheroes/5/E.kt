//BROKEN

//It maximizes the SUM instead of the MIN


fun docase(nextLine: () -> String){
    val n = nextLine().toInt()
    val a = nextLine().split(" ").map { it.toInt() }
    val b = nextLine().split(" ").map { it.toInt() }
 
    //val r = a.zip(b.reversed()).map { (it.first - it.second).absoluteValue }.sum()

 
    val r = (1..n).reversed().joinToString (" ")
 
    println(r) ;
   // println(" => $count");
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
