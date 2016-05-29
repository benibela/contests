#include <message.h>
#include <cassert>
#include <cstdio>
#include <algorithm>
#include <map>


#include <climits>

#include "rps.h"

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


int main() {
  int n = GetN();
  int len = (1 << n);
  int basenodes = NumberOfNodes();
  int my_id = MyNodeId();
  long long maxi = LLONG_MIN;
  long long mini = LLONG_MAX;

  int nodes = 1;
  while (nodes * 2 < basenodes) nodes *= 2;
  if (nodes > len) nodes = len;

  int masterNode = 0;
  if (nodes < basenodes) masterNode = nodes;

  //fprintf(stderr, "%d %d %d\n", basenodes, nodes, masterNode);

  if (my_id < nodes) {
       int slicelen = (1 << GetN()) / nodes;
       char * data = new char[slicelen];
       int offset = slicelen * my_id ;
       for (int i=0;i<slicelen;i++)
            data[i] = GetFavoriteMove(i + offset);
       curTo = masterNode;
       int winner = solve(data, slicelen);
       put(winner + offset);
       put(data[winner]);
       send();
  }

  if (my_id == masterNode) {
       char * data = new char[nodes];
       int * ids = new int[nodes];
       for (int i=0;i<nodes;i++){
            receive(i);
            get(&ids[i]);
            get(&data[i]);
       }
       printf("%d\n", ids[solve(data, nodes)]);
  }



  return 0;
}


