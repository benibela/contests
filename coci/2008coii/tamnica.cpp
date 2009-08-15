#include <iostream>
#include <queue>
#include <set>
#include <math.h>

typedef long long int int64;
using namespace std;
long int findSite(int64 k){ 
  int64 m = (int64)floor(sqrt(k))-2;
  if (m<0) m=0;
  int64 n = 2*m;
  int64 r = 3*m+m*m+4;
  while (r<=k) {
    n++;
    r+=1+n/2;
  }
  return n;
}

struct mypair{
  int64 dist;
  long int pos;
  mypair (int64 d, long int p){
    dist=d;
    pos=p;
  }
};

bool operator< (const mypair &a, const mypair &b){
  if (a.dist>b.dist) return true;
  else if (a.dist<b.dist) return false;
  else return a.pos<b.pos;
}

  priority_queue<mypair> q=priority_queue<mypair>();
  bool visited[400000];
  int64 rid[400000];
  int64 bestDist[400000];
  set<long int> toVisit=set<long int>();
int main(){
  int64 N = 0;/*
while (1) {
scanf("%lli",&N);
printf("%li\n",findSite(N));
printf("%lli\n",N-2*findSite(N)-1);
}*/
  long int k=0;
  scanf("%lli",&N);
  scanf("%li",&k);
  long int p=0;
  for (long int i=0;i<k;i++){
    int64 B=0,A;
    scanf("%lli",&B);
    
    A = B - 2*findSite(B) - 1;
    
    //printf("%li %i %i\n",p,(int)A,(int)B);

    rid[++p]=A;visited[p]=false;q.push(mypair(A-1,p));bestDist[p]=A-1;toVisit.insert(p);
    rid[++p]=B;visited[p]=false;q.push(mypair(B-1,p));bestDist[p]=B-1;toVisit.insert(p);
    
  }
  //printf("\n");
  int64 bestDistance = N - 1;
  while (!q.empty()) {
    mypair cu = q.top();
    q.pop();
    //printf("%li %i: %i %i\n",cu.pos,(int)rid[cu.pos],(int)cu.dist,(int)bestDistance);
    if (cu.dist>=bestDistance) break;
    //printf("a\n");
    if (visited[cu.pos]) continue;
    visited[cu.pos] = true;
    toVisit.erase(cu.pos);
    //printf("W s%li %i: %i %i\n",cu.pos,(int)rid[cu.pos],(int)cu.dist,(int)bestDistance);
    if ((cu.pos & 1 == 0) && !visited[cu.pos-1]) {
  //    visited[cu.pos-1]=true;
      q.push(mypair(cu.dist+1,cu.pos-1));
      if (bestDist[cu.pos-1]>cu.dist+1) bestDist[cu.pos-1]=cu.dist+1;
      if (rid[cu.pos-1]==N) {
        bestDistance = cu.dist+1;
        break;
      }
    } else if ((cu.pos & 1 != 0) && !visited[cu.pos+1]) {
//      printf("tw %i: %i\n",(int)rid[cu.pos+1], (int)cu.dist+1);
      q.push(mypair(cu.dist+1,cu.pos+1));
      if (bestDist[cu.pos+1]>cu.dist+1) bestDist[cu.pos+1]=cu.dist+1;
      if (rid[cu.pos+1]==N) {
        bestDistance = cu.dist+1;
        break;
      }
    }
    if (abs(N-rid[cu.pos])+cu.dist < bestDistance) bestDistance=abs(N-rid[cu.pos])+cu.dist;
    for (set<long int>::iterator it=toVisit.begin();it!=toVisit.end();it++){
      long int i = *it;
      int64 nd=abs(rid[i]-rid[cu.pos])+cu.dist;
      if (nd<bestDist[i]) {
        bestDist[i]=nd;
        q.push(mypair(nd,i));
      }
    }
  }
  
  printf("%lli",bestDistance);
  
  exit (0);
}
