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
     scanf("%i\n", &T);
     forr (tt, 1, T) {

          int N;
          scanf("%i\n", &N);

          printf("Case #%i:", tt);

          int P[30]; int Ps = 0;
          fori (i, N) { scanf("%i", &P[i]); Ps += P[i]; }

          while (Ps > 0) {
               int max1 = 0;
               fori(i,N) if (P[i] > P[max1]) max1 = i;
               int max2 = (max1 == 0) ? 1 : 0;
               fori(i,N) if (P[i] > P[max2] && i != max1) max2 = i;
               int max3 = (max1 == 0) ? (max2 ==1?2:1) : 0;
               fori(i,N) if (P[i] > P[max3] && i != max1 && i != max2) max3 = i;

               int majo = (Ps / 2) - 1;
               if (max3 < N && P[max3] > majo) {
                    fprintf(stderr,"assumption failed: #%i %i @ %i=%i\n", tt, majo, max3, P[max3]);
                    majo = Ps / 2;
                    if (P[max2] > majo) {
                         fprintf(stderr,"assumption 2 failed: %i!!!!!!!!!!!11\n", tt);
                    }
                    printf(" %c", 'A' + max1);
                    P[max1]--;
                    Ps -= 1;
               } else {
                    Ps -= 2;
                    P[max1]--;
                    P[max2]--;
                    printf(" %c%c", 'A' + max1, 'A' + max2);
               }
          }

          printf("\n");
          //printf("%i %i\n", deceiveScore, warScore);
     }
    // for (int i=3;basecache[i];i++)
    //      printf("%lli\n", basecache[i]);
}
