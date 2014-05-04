#include <cstdio>
#include <set>

using namespace std;

#define forr(i,f,t) for (int i = (f); i <= (t); i++)
#define fori(i,t) for (int i = 0; i < (t); i++)
#define forc(i,c) for (int i = 0; i < (c).size(); i++)

void rerase(set<double>& s, const set<double>::const_reverse_iterator &it ) {
     s.erase(s.find(*it));
}

int main(int argc, char *argv[])
{
     int T;
     scanf("%i", &T);
     forr (t, 1, T) {
          printf("Case #%i: ", t);

          int N;
          scanf("%i\n", &N);
          set<double> nn, kk;
          fori (i, N) {
               double t;
               scanf("%lf", &t);
               nn.insert( t);
          }
          fori (i, N) {
               double t;
               scanf("%lf", &t);
               kk.insert(t);
          }
          fprintf(stderr, "A: %i %i", nn.size(), kk.size());

          set<double> n, k;

          n = nn;
          k = set<double>(kk.begin(), kk.end());
          int warScore = 0;
          for (set<double>::const_iterator it = n.begin(); it != n.end(); it++){
               double c = *it;
               if (c > *k.rbegin()) { k.erase(k.begin()); warScore ++; }
               else k.erase(k.lower_bound(c));
          }

          k = set<double>(kk.begin(), kk.end());
          int warScore2 = 0;
          for (set<double>::const_reverse_iterator it = n.rbegin(); it != n.rend(); it++){
               double c = *it;
               if (c > *k.rbegin()) { k.erase(k.begin()); warScore2 ++; }
               else k.erase(k.lower_bound(c));
          }
          if (warScore != warScore2) {  printf("WTF: %i <> %i\n", warScore, warScore2); return -1;}


          int deceiveScore = 0;
          k = set<double>(kk.begin(), kk.end());
          fprintf(stderr, "%i %i\n", k.size(), n.size());
          fori (i, N) {
               if (*n.rbegin() < *k.rbegin()) {
                    n.erase(n.begin());
                    rerase(k,k.rbegin());
               } else {
                    rerase(n,n.rbegin());
                    rerase(k,k.rbegin());
                    deceiveScore++;
               }
          }

          printf("%i %i\n", deceiveScore, warScore);
     }
}
