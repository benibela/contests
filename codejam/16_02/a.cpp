#include <cstdio>
#include <set>
#include <string>
//#include <algorithm>
#include <vector>
#include <cstdint>

using namespace std;
//--common
#define forr(i,f,t) for (int i = (f); i <= (t); i++)
#define fori(i,t) for (int i = 0; i < (t); i++)
#define forc(i,c) for (int i = 0; i < (c).size(); i++)
#define forit(it,c) for (auto it = (c).begin(), end = (c).end(); it != end; ++it)

template <typename C> void rerase(C& s, const typename C::const_reverse_iterator &it ) { s.erase(s.find(*it)); }
template <typename T> vector<T>& operator<<(vector<T>& v, const T& t) { v.push_back(t); return v; }
template <typename T> set<T>& operator<<(set<T>& v, const T& t) { v.insert(t); return v; }
//--end common

#include "QList"
#include "QPair"


int main(int argc, char *argv[])
{
     int T;
   /*  printf("%d\n", sizeof(int));
     printf("%d\n", sizeof(long));
     printf("%d\n", sizeof(long int));
     printf("%d\n", sizeof(long long int));

     printf("%d\n", (int)(0xdeadbeef));
     printf("%ld\n", (int)(0xdeadbeef));
     printf("%lld\n", (int)(0xdeadbeef));*/

     char * buf1 = new char[2 << 12];
     char * buf2 = new char[2 << 12];
     char * candidatesolution = new char[2 << 12];
     char * solution;
     char * target = buf1;
     char * src = buf2;


     scanf("%i\n", &T);
     forr (tt, 1, T) {

          int n,S,P,R;
          scanf("%i %i %i %i\n", &n, &R, &P, &S);

          solution = "IMPOSSIBLE";

          for (int c=1;c<=3;c++) {
               int len = 1;

               if (c == 1) target[0] = 'P';
               else if (c == 2) target[0] = 'R';
               else if (c == 3) target[0] = 'S';

               len = 1;
               for (int i=1;i<=n;i++) {
                    swap(target, src);
                    for (int j=0;j<len;j++) {
                         if (src[j] == 'P') { target[2*j] = 'P'; target[2*j+1] = 'R'; }
                         else if (src[j] == 'R') { target[2*j] = 'R'; target[2*j+1] = 'S'; }
                         else if (src[j] == 'S') { target[2*j] = 'P'; target[2*j+1] = 'S'; }
                    }
                    len *= 2;
               }

               int p = 0; int r = 0; int s = 0;
               for (int j=0;j<len;j++)
                    if (target[j] == 'P') p++;
                    else if (target[j] == 'R') r++;
                    else if (target[j] == 'S') s++;
               if (p != P || s != S || r != R) continue;

               target[len] = '\0';
               src[len] = '\0';
               int sublen = 1;
               for (int i=1;i<=n && sublen < len;i++) {
                    swap(target, src);
                    for (int j=0;j<len;j+=2*sublen) {
                         bool ok = true;
                         for (int k=0;k<sublen;k++)
                              if (src[j+k] != src[j+k+sublen]) {
                                   ok = src[j+k] < src[j+k+sublen];
                                   break;
                              }
                         if (ok) {
                              for (int k=0;k<sublen*2;k++) target[j+k] = src[j+k];
                         } else {
                              for (int k=0;k<sublen;k++) {
                                   target[j+k] = src[j+k+sublen];
                                   target[j+k+sublen] = src[j+k];
                              }
                         }
                    }
                    sublen *= 2;
               }

               if (solution == candidatesolution) {
                    bool oldbetter = true;
                    for (int j=0;j<=len;j++)
                         if (candidatesolution[j] != target[j]) {
                              oldbetter = candidatesolution[j] < target[j];
                              fprintf(stderr, ">%d", (int)(oldbetter));
                              break;
                         }
                    if (oldbetter ) continue;
               }

               for (int j=0;j<=len;j++) candidatesolution[j] = target[j];
               solution = candidatesolution;

               break;
          }



          printf("Case #%i: %s", tt, solution);

          printf("\n");
      }

}
