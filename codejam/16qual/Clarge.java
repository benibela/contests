/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

import java.math.BigInteger;
        

/**
 *
 * @author benito
 */
public class Clarge {

 final int caseN = 32;
 final int caseJ = 500;

 BigInteger[] primes = new BigInteger[]{ new BigInteger("2"), new BigInteger("3"), new BigInteger("5"), new BigInteger("7"), new BigInteger("11") };
 BigInteger bases[][] = new BigInteger[11][50];
 BigInteger jamInBases[] = new BigInteger[11];
 boolean jam[] = new boolean[caseN];
 BigInteger witness[] = new BigInteger[11];

  boolean isJam(){
      boolean okInBase = false;
      for (int b=2;b<=10;b++) {
          okInBase = false;
          jamInBases[b] = BigInteger.ZERO;
          for (int i=0;i<caseN;i++)
              if (jam[i])
                jamInBases[b] = jamInBases[b].add(bases[b][i]);
          for (BigInteger p: primes)
              if (jamInBases[b].mod(p).equals(BigInteger.ZERO)) {
                  witness[b] = p;
                  okInBase = true;
                  break;
              }
          if (!okInBase) return false;
      }
      return true;
  }

  public static void main(String[] args) { new Alarge().run(); }

  public void run(){
      for (int b = 2; b <= 10; b++) {
          bases[b][0] = BigInteger.ONE;
          for (int j=1;j<bases[b].length;j++)
              bases[b][j] = bases[b][j-1].multiply(new BigInteger(b+""));
      }
      System.out.println("Case #1:");
      jam[0] = true;
      jam[caseN-1] = true;
      int foundJ = 0;
      while (foundJ < caseJ) {
          if (isJam()) {
              System.out.print(jamInBases[10]);
              for (int b=2;b<=10;b++)
                  System.out.print(" " + witness[b]);
              System.out.println();
              foundJ ++;
          }

          int i = 1;
          while (i < caseN && jam[i]) i++;
          for (int j=1;j<=i;j++) jam[j] = false;
          jam[i] = true;
      }
  }
  
}
