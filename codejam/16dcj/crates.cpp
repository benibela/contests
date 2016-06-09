#include <message.h>
#include <cassert>
#include <cstdio>
#include <algorithm>
#include <map>


#include <climits>

#include "crates.h"

int curTo = 0;
void put(char value) { PutChar(curTo, value); }
void put(int value) { PutInt(curTo, value); }
void put(long long value) { PutLL(curTo, value); }
void send() { Send(curTo); }

int curFrom = 0;
void receive(int from = -1){
  curFrom = Receive(from);
}
void get(char *value) { *value = GetChar(curFrom); }
void get(int *value) { *value = GetInt(curFrom); }
void get(long long *value) { *value = GetLL(curFrom); }

using namespace std;

int solve(char* data, int len){
     int * ids = new int[len];
     for (int i=0;i<len;i++) ids[i] = i;

     while (len > 1) {
          int j = 0;
          for (int i=0;i<len;i+=2,j++) {
               if (data[ids[i]] == 'R' && data[ids[i+1]] == 'P')  ids[j] = ids[i+1];
               else if (data[ids[i]] == 'P' && data[ids[i+1]] == 'S')  ids[j] = ids[i+1];
               else if (data[ids[i]] == 'S' && data[ids[i+1]] == 'R')  ids[j] = ids[i+1];
               else ids[j] = ids[i];
          }
          len /= 2;
     }
     return ids[0];
}

const long long MOD = 1000000007LL;

int main() {
  int n = GetNumStacks();
  int nodes = NumberOfNodes();
  int id = MyNodeId();

  //nodes = 1;

  int slicelen = ( (n + nodes - 1)  / nodes);
  int * slicelens = new int[nodes];
  int * offsets = new int[nodes];
  int tempcount = 0;
  for (int i=0;i<nodes;i++) {
       offsets[i] = tempcount;
       slicelens[i] = slicelen;
       if (offsets[i] + slicelens[i] > n) slicelens[i] = n - offsets[i];
       if (slicelens[i] <= 0) {
            nodes = i;
            break;
       }
       tempcount += slicelens[i];
  }
  if (id >= nodes) return 0;
  int offset = offsets[id] + 1;
  int mylen = slicelens[id];

  long long localcount = 0;

  int *data = new int[mylen];
  for (int i=0,j=offset;i<mylen;i++,j++) {
       data[i] = GetStackHeight(j);
       localcount += data[i];
  }

  fprintf(stderr,"lc:%d\n",localcount);

  long long totalcount = 0;
  long long leftmost;
  long long target;
  long long incoming = 0;
  long long result = 0;
  if (id) {
     curTo = 0;
     put(localcount);
     send();

     receive();
     get(&totalcount);
     get(&incoming);

     //target = (totalcount + (id < leftmost ? n - 1 : 0) ) / n;
     leftmost = totalcount % n;
     target = totalcount / n;

  } else {
       long long *counts = new long long [nodes];
       //long long targets = new long long [nodes];

       counts[0] = localcount;
       totalcount = localcount;
       for (int i=1;i<nodes;i++) {
            receive();
            get(&localcount);
            totalcount += localcount;
            counts[curFrom] = localcount;
       }

       leftmost = totalcount % n;
       target = totalcount / n;

       long long rleftmost = leftmost;
       long long traveling = 0;
       for (int i=0;i<nodes;i++) {
            int curlen = slicelens[i];

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
            curTo = i;
            put(totalcount);
            put(counts[i]);
            send();
       }
  }

  fprintf(stderr, "%lld %lld %lld\n", incoming, localcount, target );

  for (int i=0,j=offset;i<mylen;i++,j++) {
       //data[i] = GetStackHeight(j);
       long long curtarget = target;
       if (j <= leftmost) curtarget++;
       long long stack = data[i] - curtarget;

       result += (incoming < 0 ? -incoming : incoming);
       incoming = incoming + stack;
       if (result > MOD) result = result % MOD;
  }

  if (id) {
     curTo = 0;
     put(result);
     send();
  } else {
       for (int i=1;i<nodes;i++) {
            receive();
            long long temp;
            get(&temp);
            result += temp;
            if (result > MOD) result = result % MOD;
       }
       result = result % MOD;
       printf("%lld\n", result);
  }


  return 0;
}


