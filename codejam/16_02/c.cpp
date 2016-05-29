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

typedef vector<int> State;

int toptargets, bottomtargets[200];

const int deadlink = 1000;

int R;

bool solve(const State& state) {
     int C = state[R];

     const int newstatebottom = 1 << (R - 1) ;

     State outstate(R+1);
     outstate[R] = C-1;
     for (int ccur = 0, end = 1 << R; ccur < end; ccur++ ) {
          //0:  \
          //1:  /

          if (toptargets[c]) {
               if ((ccur & 1) == 0) {
                    if (state[0] == deadlink) continue;
                    //if (state[0] == toptargets[c]) ; //ok
                    //else if (state[0] < deadlink)
               }
          }
          if (bottomtargets[c]) {
               if (ccur & newstatebottom == 1)
                    if (state[r-1] == deadlink) continue;
          }

          for (int i=0;i<R;i++) {
               int pos = i;
               while (pos >= 0 && pos < R)
               if ((cur && (1 << pos)) == 0 ) {
                    pos++;
                    if (pos >= R) pos = bottomtargets[c];
                    else if ((cur && (1 << pos)) == 0 ) {
               else pos--;
               if (pos < 0) outstate[i] = toptargets[c];
               else if (pos >= R) outstate[i] = bottomtargets[c];
               else {
                    pos = state[pos];
                    if (pos >= 0 && pos < R) {
                         if ((cur && (1 << pos)) == 0 ) pos--;
                         else pos++;
                    }
               }
          }

          if (R > 1) {
               if ((ccur & 1) == 0) {
                    if ((ccur & 2) == 0) outstate[0] = state[1];
                    else outstate[0] = 1;
               } else {
                    if (toptargets[c]) outstate[0] = toptargets[c];
                    else outstate[0] = deadlink;
               }

               if ((ccur & newstatebottom) == 0) {
                    if (bottomtargets[c]) outstate[R-1] = bottomtargets[c];
                    else outstate[R-1] = deadlink;
               } else {
                    if ((ccur & (newstatebottom << 1)) == 0) outstate[R-1] = R-2;
                    else outstate[R-1] = state[R-2];
               }
          } else {

          }
                    if ((ccur & 2) == 0) outstate[0] = state[1];
                    else outstate[0] = 1;
               }
          }


          for (int i=1;i<R-1;i++)
               if ((cur & (1 << i)) == 0) {
                    if ((ccur & (1 << (i+1))) == 0) outstate[i] = state[i+1];
                    else outstate[i] = i+1;
               } else {
                    if ((ccur & (1 << (i-1))) == 0) outstate[i] = i-1;
                    else outstate[i] = state[i-1];
               }

     }
}

int main(int argc, char *argv[])
{int T;
     //cout << dec("1490", "?2??", 1);
     scanf("%i\n", &T);
     forr (tt, 1, T) {

          //int N;
          //scanf("%i\n", &N);





          printf("Case #%i:", tt);

          printf("\n");


     }
     //cout << inc("480", "4?0", 2);
}
