#include <message.h>
#include <cassert>
#include <cstdio>
#include <algorithm>
#include <map>
#include <set>
#include <vector>
#include <string.h>

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

  template <typename Data> pipe& operator<<(const Data& data) {
    //int buffer[sizeof(data) / sizeof(int)];
    //memcpy(&buffer[0], &data, sizeof(buffer));
    char buffer[sizeof(data)];
    memcpy(&buffer[0], &data, sizeof(data));
    int i=0;
    for (;i<sizeof(buffer);i+=sizeof(ll)) *this << *(ll*)(&buffer[i]);
    for (;i<sizeof(buffer);i+=sizeof(int)) *this << *(int*)(&buffer[i]);
    for (;i<sizeof(buffer);i++) *this << buffer[i];
    return *this;
  }
  template <typename Data> pipe& operator>>(Data& data) {
    //int buffer[sizeof(data) / sizeof(int)];
    //memcpy(&buffer[0], &data, sizeof(buffer));
    char buffer[sizeof(data)];
    int i=0;
    for (;i<sizeof(buffer);i+=sizeof(ll)) *this >> *(ll*)(&buffer[i]);
    for (;i<sizeof(buffer);i+=sizeof(int)) *this >> *(int*)(&buffer[i]);
    for (;i<sizeof(buffer);i++) *this >> buffer[i];
    memcpy(&data, &buffer[0], sizeof(data));
    return *this;
  }

  template <typename Data> pipe& operator<<(const vector<Data>& data) {
    *this << (ll)data.size();
    for (int i=0;i<data.size();i++) *this << data[i];
  }
  template <typename Data> pipe& operator>>(vector<Data>& data) {
    ll size;
    *this >> size;
    data.resize(size);
    for (int i=0;i<data.size();i++) *this >> data[i];
  }

  pipe& operator<< (int data) {
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
template<typename Reducer, typename Data> void clusterReduce(Data& local)
{
  if (id) {
    pipe(0) << local >> local;
  } else {
    Reducer red;
    for (int i=1;i<nodes;i++) {
      pipe p(i);
      Data temp;
      p >> temp;
      red(local, temp);
    }
    for (int i=1;i<nodes;i++) {
      pipe p(i);
      p << local;
    }
  }
}

template<typename Reducer, typename Data> void localReduce(Data& local, ll offset, ll length){
  Reducer red;
  if (length > 0) {
    red.getData(local, offset);
    offset++; length--;
    Data temp;
    for (;length;offset++, length--) {
      red.getData(temp, offset);
      red(local, temp);
    }
  }
}

template<typename Reducer, typename Data> void fullReduce(Data& local, ll length){
  ll offset, sublength;
  calcslice(length, &offset, &sublength);
  localReduce<Reducer,Data>(local, offset, sublength);
  clusterReduce<Reducer,Data>(local);
}

template<typename Reducer, typename Data> Data fullReduce(ll length){
  Data res;
  fullReduce<Reducer,Data>(res, length);
  return res;
}

struct ReducerSum{ void operator()(ll& a, const ll& b) { a += b; } };
struct ReducerMax{ void operator()(ll& a, const ll& b) { if (b > a) a = b; } };
struct ReducerMin{ void operator()(ll& a, const ll& b) { if (b < a) a = b;  } };

void clusterSum(ll& local) { clusterReduce<ReducerSum>(local); }
void clusterMax(ll& local) { clusterReduce<ReducerMax>(local); }
void clusterMin(ll& local) { clusterReduce<ReducerMin>(local); }

void init (){
  nodes = NumberOfNodes();
  id = MyNodeId();
}


struct MinMax {
  ll mini, maxi;
  MinMax(){
    mini = LLONG_MAX;
    maxi = LLONG_MIN;
  }
};



struct ReducerMinMax {
  void operator()(MinMax& a, const MinMax& b) {
    if (b.maxi > a.maxi) a.maxi = b.maxi;
    if (b.mini < a.mini) a.mini = b.mini;
  }

  void getData(MinMax& res, ll i);
};

#include "winning_move.h"

void ReducerMinMax::getData(MinMax& res, ll i) {

}



int xhash(ll sub){
  return ((sub * 0x1010101010101010) ^ sub) % nodes;
}


int main() {
  init();

  ll N = GetNumPlayers();
  set<ll> seen;
  set<ll> candidates;
  for (ll i=id;i<N;i+=nodes) {
    ll sub = GetSubmission(i);
    if (seen.find(sub) == seen.end()) {
      seen.insert(sub);
      candidates.insert(sub);
    } else candidates.erase(sub);
  }
  vector<ll> candies[nodes];
  for (set<ll>::iterator it = candidates.begin(), end = candidates.end(); it != end; ++it) {
    candies[xhash(*it)].push_back(*it);
  }
  for (int i=0;i<nodes;i++)
    pipe(i) << candies[i];

  candidates.clear();
  seen.clear();
  for (int i=0;i<nodes;i++) {
    vector<ll> temp;
    pipe(i) >> temp;
    for (int i=0;i<temp.size();i++) {
      ll sub = temp[i];
      if (seen.find(sub) == seen.end()) {
        seen.insert(sub);
        candidates.insert(sub);
      } else candidates.erase(sub);
    }
  }

  ll minimal = N + 1;
  for (set<ll>::iterator it = candidates.begin(), end = candidates.end(); it != end; ++it) {
    if (*it < minimal) minimal = *it;
  }

  pipe(0) << minimal;
  if (!id) {
    for (int i=0;i<nodes;i++) {
      ll temp;
      pipe(i) >> temp;
      if (temp < minimal && temp <= N) minimal = temp;
    }
    if (minimal > N) minimal = 0;
    printf("%lld\n", minimal);
  }


  return 0;
}


