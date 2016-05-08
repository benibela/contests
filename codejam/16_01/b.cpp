#include <cstdio>
#include <set>
#include <string>
#include "stdlib.h"
//#include <algorithm>
#include <vector>
#include <iostream>

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


string inc(string s, char* marks, int& pos) {
     while (pos >= 0 && marks[pos] != '?')  pos--;
     if (pos < 0) return s;
     string r = s;
     r[pos]++;
     while (pos >= 0 && r[pos] > '9') {
          r[pos] = '0';
          pos--;
          while (pos >= 0 && marks[pos] != '?')  pos--;
          if (pos<0) break;
          r[pos]++;
     }
     if (pos < 0) return s;
     return r;
}

string dec(string s, char* marks, int& pos) {
     while (pos >= 0 && marks[pos] != '?')  pos--;
     if (pos < 0) return s;
     string r = s;
     r[pos]--;
     while (pos >= 0 && r[pos] < '0') {
          r[pos] = '9';
          pos--;
          while (pos >= 0 && marks[pos] != '?')  pos--;
          if (pos<0) break;
          r[pos]--;
     }
     if (pos < 0) return s;
     return r;
}

void complete(string& s, char* marks, int delta, char insert) {
     for (int i=delta+1;i<s.size();i++)
          if (marks[i] =='?') s[i] = insert;
}

uint64_t score(const string& s, const string&t) {
     uint64_t si = strtoull(s.c_str(), 0, 10);
     uint64_t ti = strtoull(t.c_str(), 0, 10);
     if (si > ti) return si - ti;
     else return ti - si;
}

void compare(string& C, string& J, string Cc, string Jc){
     if (score(C,J) < score(Cc, Jc)) return;
     if (score(C,J) == score(Cc, Jc)) {
          if (C < Cc) return;
          if (C == Cc && J < Jc) return;
     }
     C = Cc;
     J = Jc;
}

void bf(string &C, string& J, string Cc, string Jc){
     for (int i=0;i<Cc.size();i++)
          if (Cc[i] == '?') {
               string temp = Cc;
               for(int d =0;d<10;d++){
                    temp[i] = d + '0';
                    bf(C,J,temp,Jc);
               }
               return;
          }
     for (int i=0;i<Jc.size();i++)
          if (Jc[i] == '?') {
               string temp = Jc;
               for(int d =0;d<10;d++){
                    temp[i] = d + '0';
                    bf(C,J,Cc,temp);
               }
               return;
          }
     compare(C,J,Cc,Jc);
}

int main(int argc, char *argv[])
{
     //cout << dec("1490", "?2??", 1);
     int T;
     scanf("%i\n", &T);
     forr (tt, 1, T) {

          char Cc[100], Jc[100];//, Cout[100], Jout[100];
          scanf("%s %s\n", Cc, Jc);
          string C = Cc;
          string J = Jc;
          string Cout, Jout;

          int delta = -1;
          fori (i, C.size())
            if (C[i] != J[i] && C[i] != '?' && J[i] != '?') {
              delta = i;
              break;
            } else {
               if (C[i] == J[i]) {
                    if (C[i] == '?') C[i] = '0', J[i] = '0';
               } else if (C[i] == '?') C[i] = J[i];
               else if (J[i] == '?') J[i] = C[i];
            }
          if (delta == -1) {
               Cout = C;
               Jout = J;
          } else {
               string C2,J2,C3,J3;
               if (C[delta] < J[delta]) {
                    int delta2 = delta, delta3 = delta;
                    C2 = inc(C,Cc,delta2); J2 = J;
                    C3 = C; J3 = dec(J,Jc,delta3);
                    complete(C,Cc,delta,'9'); complete(J,Jc,delta,'0');
                    complete(C2,Cc,delta2,'0'); complete(J2,Jc,delta2,'9');
                    complete(C3,Cc,delta3,'0'); complete(J3,Jc,delta3,'9');
                    //printf("<");
               } else { //C > J
                    int delta2 = delta, delta3 = delta;
                    C2 = dec(C,Cc,delta2); J2 = J;
                    C3 = C; J3 = inc(J,Jc,delta3);
                    complete(C,Cc,delta,'0'); complete(J,Jc,delta,'9');
                    complete(C2,Cc,delta2,'9'); complete(J2,Jc,delta2,'0');
                    complete(C3,Cc,delta3,'9'); complete(J3,Jc,delta3,'0');
                    //printf(">");
               }
               Cout = C;
               Jout = J;
               //printf("%s %s candidates %s %s     %s %s     %s %s => ",Cc,Jc,Cout.c_str(), Jout.c_str(),C2.c_str(), J2.c_str(),C3.c_str(), J3.c_str());
               compare(Cout, Jout, C2, J2);
               compare(Cout, Jout, C3, J3);
          }

          //bf(Cout, Jout, Cc, Jc);

          printf("Case #%i: %s %s\n", tt, Cout.c_str(), Jout.c_str());


     }
     //cout << inc("480", "4?0", 2);
}
