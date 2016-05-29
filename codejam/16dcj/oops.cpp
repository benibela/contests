#include <message.h>
#include <cassert>
#include <cstdio>
#include <algorithm>
#include <map>


#include <climits>

#include "oops.h"

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


#define MASTER_NODE 0
#define DONE -1

int main() {
  long long N = GetN();
  long long nodes = NumberOfNodes();
  long long my_id = MyNodeId();
  long long maxi = LLONG_MIN;
  long long mini = LLONG_MAX;

  for (long long i = my_id; i < N; i+=nodes) {
    long long l = GetNumber(i);
    if (l < mini) mini = l;
    if (l > maxi) maxi = l;
  }

  if (my_id == MASTER_NODE) {
       long long global_mini = mini;
       long long global_maxi = maxi;
         for (int node = 1; node < nodes; ++node) {
           Receive(node);
           mini = GetLL(node);
           maxi = GetLL(node);
           if (mini < global_mini) global_mini = mini;
           if (maxi > global_maxi) global_maxi = maxi;
         }
     printf("%lld\n", global_maxi - global_mini);
  } else {
       PutLL(MASTER_NODE, mini);
       PutLL(MASTER_NODE, maxi);
       Send(MASTER_NODE);
  }
  return 0;
}


