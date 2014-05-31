#include <cstdio>
#include <set>
#include <string>
//#include <algorithm>
#include <vector>

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
     int T;
     scanf("%i", &T);
     forr (tt, 1, T) {
          int N;
          scanf("%i\n", &N);
          int n = N;
          vector<int> v;
          v.resize(N);
          fori(i, N) scanf("%d", &v[i]);

          int best = 0;
          fori (i, n) {
               auto mini = v.begin();
               forit (it, v) if (*it < *mini) mini = it;
               int p = mini - v.begin();
               if (p < v.size() - p - 1) best += p;
               else best += v.size() - p - 1;
               v.erase(mini);
          }

/*
          int invUp[2000], invDown[2000];
          invUp[0] = 0;
          for (int i=1;i<n;i++) {
               invUp[i] = invUp[i-1];
               fori (j, i)
                   if (v[j] > v[i] ) invUp[i] ++;
          }
          invDown[n-1] = invDown[n] = 0;
          for (int i=n-2;i>=0;i--) {
               invDown[i] = invDown[i+1];
               for (int j=n-1;j>i;j--)
                   if (v[j] > v[i] ) invDown[i] ++;
          }

          int best = n * n;
          fori(i, n) if (invUp[i] + invDown[i+1] < best) best = invUp[i] + invDown[i+1];

          printf("\nUp  : ");
          fori(i,n) printf("%d ",invUp[i]);
          printf("\nDown: ");
          fori(i,n) printf("%d ",invDown[i]);*/

          printf("Case #%i: %d\n", tt, best);
          //printf("%i %i\n", deceiveScore, warScore);
     }
}
