#include <cstdio>
#include <set>
#include <string>
#include <algorithm>
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
          int N, c;
          scanf("%d %d\n", &N, &c);
          vector<int> v;
          v.resize(N);
          fori(i, N) scanf("%d", &v[i]);
          std::sort(v.begin(), v.end());
          reverse(v.begin(), v.end());

          int disks = 0;

          while (v.size()) {
               disks ++;
               int d = c - v[0];
               v.erase(v.begin());
               forit (it, v) if (*it <= d) {v.erase(it); break;}
          }


          printf("Case #%i: %i\n", tt, disks);
          //printf("%i %i\n", deceiveScore, warScore);
     }
}
