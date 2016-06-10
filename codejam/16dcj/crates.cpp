#include <message.h>
#include <cassert>
#include <cstdio>
#include <algorithm>
#include <map>
#include <climits>

typedef long long ll;
using namespace std;

void calcslice(int id, int nodes, ll n, ll * offset, ll* length) {
  ll temp, temp2;
  if (!offset) offset = &temp;
  if (!length) length = &temp2;
  *length = (n + nodes - 1) / nodes;
  *offset = *length * id;
  if (*offset + *length >= n)  {
    *length = n - *offset;
    if (*length < 0) { *length = 0; *offset = n; }
  }
}

int id;
int nodes;

void calcslice(ll n, ll * offset, ll* length) {
  calcslice(id, nodes, n, offset, length);
}

enum PipeDir { PD_EMPTY, PD_SEND, PD_RECEIVE };
struct pipe{
  int target;
  int dir;
  pipe(int t): target(t), dir(PD_EMPTY) { }
  ~pipe(){ flush(PD_EMPTY); }

  void flush(PipeDir newDir){
    if (dir == newDir) return;
    if (dir == PD_SEND) Send(target);
    dir = newDir;
    if (newDir == PD_RECEIVE) Receive(target);
  }

  pipe& operator<<(int data) {
    flush(PD_SEND);
    PutInt(target, data);
    return *this;
  }
  pipe& operator<<(ll data) {
    flush(PD_SEND);
    PutLL(target, data);
    return *this;
  }
  pipe& operator<<(char data) {
    flush(PD_SEND);
    PutChar(target, data);
    return *this;
  }
  ll getll() { flush(PD_RECEIVE); return GetLL(target);   }
  int getint() { flush(PD_RECEIVE); return GetInt(target);   }
  char getchar() { flush(PD_RECEIVE); return GetChar(target);   }

  pipe& operator>>(int& a) { a = getint(); return *this; }
  pipe& operator>>(ll& a) { a = getll(); return *this; }
  pipe& operator>>(char& a) { a = getchar(); return *this; }
};

//typedef ll (*ReduceFunc)(ll,ll);
template<typename Reducer> void clusterReduce(ll& local)
{
  if (id) {
    pipe(0) << local >> local;
  } else {
    Reducer red;
    for (int i=1;i<nodes;i++) {
      pipe p(i);
      local = red(local, p.getll());
    }
    for (int i=1;i<nodes;i++) {
      pipe p(i);
      p << local;
    }
  }
}

struct ReducerSum{  ll operator()(ll a, ll b) { return a + b; } };
struct ReducerMax{  ll operator()(ll a, ll b) { return a > b ? a : b; } };
struct ReducerMin { ll operator()(ll a, ll b) { return a < b ? a : b; } };

void clusterSum(ll& local) { clusterReduce<ReducerSum>(local); }
void clusterMax(ll& local) { clusterReduce<ReducerMax>(local); }
void clusterMin(ll& local) { clusterReduce<ReducerMin>(local); }

void init (){
  nodes = NumberOfNodes();
  id = MyNodeId();
}

#include "crates.h"



const long long MOD = 1000000007LL;

int main() {
  init();
  const int n = GetNumStacks();

  //nodes = 1;
  ll offset, mylen;
  calcslice(n, &offset, &mylen);

  long long localcount = 0;

  int *data = new int[mylen];
  for (int i=0,j=offset;i<mylen;i++,j++) {
       data[i] = GetStackHeight(j+1);
       localcount += data[i];
  }

  fprintf(stderr,"lc:%d\n",localcount);

  long long totalcount = 0;
  long long leftmost;
  long long target;
  long long incoming = 0;
  long long result = 0;
  if (id) {
    pipe(0) << localcount >> totalcount >> incoming;

    //target = (totalcount + (id < leftmost ? n - 1 : 0) ) / n;
    leftmost = totalcount % n;
    target = totalcount / n;

  } else {
       long long *counts = new long long [nodes];
       //long long targets = new long long [nodes];

       counts[0] = localcount;
       totalcount = localcount;
       for (int i=1;i<nodes;i++) {
         pipe(i) >> localcount;
         totalcount += localcount;
         counts[i] = localcount;
       }

       leftmost = totalcount % n;
       target = totalcount / n;

       long long rleftmost = leftmost;
       long long traveling = 0;
       for (int i=0;i<nodes;i++) {
            ll curlen;
            calcslice(i,   nodes, n, 0, &curlen);

            long long nodetarget = target * curlen;
            if (rleftmost > curlen) {
                 nodetarget += curlen;
                 rleftmost -= curlen;
            }  else {
                 nodetarget += rleftmost;
                 rleftmost = 0;
            }


            //counts[i] = oldtraveling;
            long long temp = counts[i];
            counts[i] = traveling;
            traveling += temp - nodetarget;
       }


       for (int i=1;i<nodes;i++) {
         pipe(i) << totalcount << counts[i];
       }
  }

  fprintf(stderr, "%lld %lld %lld %lld\n", incoming, localcount, leftmost, target );

  for (int i=0,j=offset;i<mylen;i++,j++) {
       //data[i] = GetStackHeight(j);
       long long curtarget = target;
       if (j + 1 <= leftmost) curtarget++;
       long long stack = data[i] - curtarget;

       result += (incoming < 0 ? -incoming : incoming);
       incoming = incoming + stack;
       if (result > MOD) result = result % MOD;
  }

  fprintf(stderr, "=> %lld %lld %lld => %lld \n", incoming, localcount, target, result );

  clusterSum(result);

  if (!id) {
       result = result % MOD;
       printf("%lld\n", result);
  }


  return 0;
}


