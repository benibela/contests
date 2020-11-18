 
fun docase(nextLine: () -> String){
    val n = nextLine().toInt()
    val a = nextLine().split(" ").map { it.toInt() }
    val ord = IntArray(a.size, { it -> 0 } )
    val actualOrd = IntArray(a.size, { it -> 0 } )
    var age = 0
    var count = 1
    for (i in 1..a.count()) {
        var found = -1;
        var foundMax = -1;
        for (j in 0 until a.count() )
            if (ord[j] == 0) {
                if (a[j] <= age) found = j;
                if (foundMax == -1 || a[j] > a[foundMax]) foundMax = j;
            }
        if (found >= 0) {
            age = 1;
            ord[found] = i;
            actualOrd[i - 1] = found + 1
            count++;
        } else{
            age ++;
            ord[foundMax] = i;
            actualOrd[i - 1] = foundMax + 1
        }
    }
    println(actualOrd.joinToString ( " ") ) ;
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
 
 
