#include <cstdio>
#include <set>
#include <string>
#include "stdlib.h"
//#include <algorithm>
#include <vector>
#include <iostream>
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

int J,P,S,K;
vector<int> Js, Ps, Ss;

int ct;
void check(int j, int p, int s)
{
     printf("%d %d %d\n", j,p,s);

     Js << j;
     Ps << p;
     Ss << s;

     int count = 0;
     fori (i, Js.size())
               if (Js[i] == j && Ps[i] == p && Ss[i] == s) count ++;
     if (count != 1) fprintf(stderr, "Repeat: %i\n", ct);

     count = 0;
     fori (i, Js.size())
               if (Js[i] == j && Ps[i] == p) count ++;
     if (count > K) fprintf(stderr, "Repeat JP: %i %i > %i\n", ct, count, K);

     count = 0;
     fori (i, Js.size())
               if (Js[i] == j && Ss[i] == s) count ++;
     if (count > K) fprintf(stderr, "Repeat JS: %i %i > %i\n", ct, count, K);

     count = 0;
     fori (i, Js.size())
               if (Ps[i] == p && Ss[i] == s) count ++;
     if (count > K) fprintf(stderr, "Repeat PS: %i %i > %i\n", ct, count, K);
}

int choose(int j, int p)
{
     for (int sx = (j+p) % S + 1; sx <= (j+p) % S + 1 + S; sx++) {
          int s = (sx - 1) % S + 1;

          int count = 0;
          fori (i, Js.size())
                    if (Js[i] == j && Ps[i] == p && Ss[i] == s) count ++;
          if (count != 0) continue;

         /* count = 0;
          fori (i, Js.size())
                    if (Js[i] == j && Ps[i] == p) count ++;
          if (count >= K) continue;*/

          count = 0;
          fori (i, Js.size())
                    if (Js[i] == j && Ss[i] == s) count ++;
          if (count >= K) continue;

          count = 0;
          fori (i, Js.size())
                    if (Ps[i] == p && Ss[i] == s) count ++;
          if (count >= K) continue;

          return s;
     }
     fprintf(stderr,"OMG\n");
     return 1;
}

int main(int argc, char *argv[])
{int T;
     //cout << dec("1490", "?2??", 1);
     scanf("%i\n", &T);
     forr (tt, 1, T) {
ct = tt;

          scanf("%d %d %d %d\n", &J,&P,&S,&K);

          Js.clear(); Ps.clear(); Ss.clear();

          printf("Case #%i: ", tt);


          if (S <= K) {
               printf("%d\n",J*P*S);
               forr (j, 1, J) forr (p, 1, P) forr (s, 1, S)
                         check(j,p,s);//    printf("%d %d %d\n", j,p,s);
          } else {
               printf("%d\n",J*P*K);
               forr (j, 1, J) forr (p, 1, P) forr (k, 1, K)
                         check(j,p,choose(j,p));// printf("%d %d %d\n", j,p,);
          }




     }
     //cout << inc("480", "4?0", 2);
}
