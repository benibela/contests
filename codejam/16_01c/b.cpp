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



int main(int argc, char *argv[])
{
     //cout << dec("1490", "?2??", 1);
     int T;
     scanf("%i\n", &T);
     forr (tt, 1, T) {

          int b; int64_t m;
          scanf("%d %ld\n", &b, &m);

          printf("Case #%i: ", tt);
          if ((((int64_t)1) << (b - 2)) >= m) {
               printf("POSSIBLE\n");
               printf("0");
               int64_t pos = (((int64_t)1) << (b - 2 - 1));
               for (int i = 1; i < b - 1; i++)  {
                    if (m >= pos) {
                         printf("1");
                         m -= pos;
                    } else printf("0");
                    pos = pos >> 1;
               }
                    //if ( (m & ((int64_t)1) << i)  == 0 ) printf("0");
                    //else printf("1");
               printf("%li\n", m);
               for (int i=1;i<b;i++) {
                    fori (j,b)
                         if (j <= i) printf("0");
                         else printf("1");
                    printf("\n");
               }

          } else printf("IMPOSSIBLE\n");



     }
     //cout << inc("480", "4?0", 2);
}
