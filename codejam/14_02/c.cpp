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

int buildtrie(vector<string>& s){
     set<string> trie;
     for (int i=0;i<s.size();i++){
          for (int j=0;j<=s[i].size();j++)
               trie << s[i].substr(0, j);
     }
     return trie.size();

}

int docount(int n, const vector<string>& s, const vector<int>& a) {
     vector<vector<string> > splitup;
     for (int i=0;i<n;i++) {
          splitup << vector<string>();
          for (size_t j=0;j<s.size();j++)
               if (a[j] == i) splitup[splitup.size()-1] << s[j];
          if (splitup[splitup.size()-1].size() == 0) return -1;
     }
     int res = 0;
     for (int i=0;i<n;i++) res += buildtrie(splitup[i]);
     return res;
}

int main(int argc, char *argv[])
{
     int T;
     scanf("%i", &T);
     forr (tt, 1, T) {
          int n, m;
          scanf("%d %d\n", &m, &n);
          vector<string> s;
          vector<int> a;
          fori (i, m){
               char buffer[100];
               scanf("%s\n", buffer);
               s << string(buffer);
               a << 0;
          //     printf("\n ==> %s\n",s[s.size()-1].c_str());
          }
          int max = 0, count = 0;
          while (a[0] < n) {
               int x = docount(n, s, a);
               if (x > max) { max = x; count = 1; }
               else if (x == max) { count++; }
               a[a.size()-1]++;
               for (int j = a.size()-1; j > 0 && a[j] >= n;j--){
                    a[j] = 0;
                    a[j-1] ++;
               }
          }



          printf("Case #%i: %i %i\n", tt, max, count);
          //printf("%i %i\n", deceiveScore, warScore);
     }
}
