    fun docase(nextLine: () -> String){
        val n = nextLine().toInt()
        val c =  nextLine().split(" ").map { it.toLong() }
     
        val r = c.map { m -> c.filter { it >= m }.count()  * m }.max()
     
        println("$r");
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
