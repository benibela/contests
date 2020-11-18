    fun docase(nextLine: () -> String){
        val (n,k) = nextLine().split(" ").map { it.toInt() }
        val p = nextLine().split(" ").map { it.toInt() }
        val r = (1..p.count()).map { count ->
            val free =count / k
            p.takeLast(count).take(free).sum()
        }.max()
        println("$r") ;
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
