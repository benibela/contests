    fun docase(nextLine: () -> String){
        val l = nextLine().trim()
        var r = l.split('w').map {
            block ->
            block.count() / 2 + 1
        }.sum() - 1
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
