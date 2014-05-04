#include <QtCore/QCoreApplication>
#include <cstdio>

#define forr(i,f,t) for (int i = (f); i <= (t); i++)
#define fori(i,t) for (int i = 0; i < (t); i++)
#define forc(i,c) for (int i = 0; i < (c).size(); i++)

int main(int argc, char *argv[])
{
     char block[100][101] = {{'.'}};
     int T;
     scanf("%i", &T);
     forr (t, 1, T) {
          printf("Case #%i:\n", t);

          int R,C,M;
          scanf("%i %i %i\n", &R, &C, &M);
          int m = M;





          if (R * C == m + 1) {
               fori (r, R) fori(c, C) block[r][c] = '*';
               m = 0;
          } else if (R == 1) {
               fori (r, R) fori(c, C) block[r][c] = '.';
               for (int c = C-1; m && c >= 0; m--, c--) block[0][c] = '*';
          } else if (C == 1) {
               fori (r, R) fori(c, C) block[r][c] = '.';
               for (int r = R-1; m && r >= 0; m--, r--) block[r][0] = '*';
          } else {
               fori (r, R) fori(c, C) block[r][c] = '.';
               int c = C - 1, r =  R - 1;
               if (C > 2 && R > 2)
               while (m > 0 && r >= 2) {
                    block[r][c] = '*';
                    c--;
                    if (c < 2) {
                         r--;
                         c = C - 1;
                    }
                    m--;
               }

               if (m > 0) {
                    if (m % 2 == 1 && R > 2 && C > 2) {
                         m ++;
                         block[2][2] = '.';
                    }
                    int subblock = (R < 3 || C < 3 || block[2][2] == '*') ? 1 : 2;
                    c = C - 1;
                    while (m >= 2 && c > subblock ) {
                         block[0][c] = block[1][c] = '*';
                         m -= 2;
                         c --;
                    }
                    r = R - 1;
                    while (m >= 2 && r > subblock ) {
                         block[r][0] = block[r][1] = '*';
                         m -= 2;
                         r --;
                    }

               }
          }

          if (m > 0) printf("Impossible\n");
          else {
               block[0][0] = 'c';
               fori (r,R) block[r][C] = '\0';
               fori (r, R) printf("%s\n", &block[r][0]);

               m = M;
               fori (r, R) fori (c, C) if (block[r][c] == '*') m--;
               if (m > 0) abort();
          }
     }
}
