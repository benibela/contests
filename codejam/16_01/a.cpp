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

#include "QList"
#include "QPair"

typedef long long int ll;

int main(int argc, char *argv[])
{
     int T;
     scanf("%i\n", &T);
     forr (tt, 1, T) {
          char uniqueOrder[][30] = {
               "6", "X", "SIX",
               "0", "Z", "ZERO",
               "2", "W", "TWO",
               "8", "G", "EIGHT",
               "3", "H", "THREE",
               "4", "R", "FOUR",
               "5", "F", "FIVE",
               "7", "V", "SEVEN",
               "1", "O", "ONE",
               "9", "I", "NINE"
          };
          int number[100] = {0};
          char line[5000];
          int histogram[256] = {0};

          scanf("%s\n", line);
          //fprintf(stderr, "??%s??",line);
          char * c = line;
          while (*c) {
               histogram[*c]++;
               c++;
          }

          //fprintf(stderr, "%i %i\n",strlen(line), histogram['R']);
          for (int i=0;i<30;i+=3) {
               int digit = uniqueOrder[i][0] - '0';
               number[digit] += (histogram[*uniqueOrder[i+1]]);
               char * d = uniqueOrder[i+2];
               for (; *d; d++) {
                    histogram[*d] -= number[digit];
               }
          }

          printf("Case #%i: ", tt);
          for (int i=0;i<10;i++) {
               for (int j=0;j<number[i];j++)
                    printf("%i", i);
          }
          printf("\n");
          //printf("%i %i\n", deceiveScore, warScore);
     }
    // for (int i=3;basecache[i];i++)
    //      printf("%lli\n", basecache[i]);
}
