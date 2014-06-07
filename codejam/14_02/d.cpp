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

#include <iostream>
#include <deque>
#include <iterator>


#include "boost/graph/graph_traits.hpp"
#include "boost/graph/adjacency_list.hpp"

using namespace boost;
/*
int s(int argc, char *argv[])
{

    //Our set of edges, which basically are just converted into ints (0-4)
    enum {A, B, C, D, E, N};


    //Example uses an array, but we can easily use another container type
    //to hold our edges.
    std::vector<Edge> edgeVec;
    edgeVec.push_back(Edge(A,B));
    edgeVec.push_back(Edge(A,D));
    edgeVec.push_back(Edge(C,A));
    edgeVec.push_back(Edge(D,C));
    edgeVec.push_back(Edge(C,E));
    edgeVec.push_back(Edge(B,D));
    edgeVec.push_back(Edge(D,E));

    //Now we can initialize our graph using iterators from our above vector
    UndirectedGraph g(edgeVec.begin(), edgeVec.end(), N);

    std::cout << num_edges(g) << "\n";

    //Ok, we want to see that all our edges are now contained in the graph
    typedef graph_traits<UndirectedGraph>::edge_iterator edge_iterator;

    //Tried to make this section more clear, instead of using tie, keeping all
    //the original types so it's more clear what is going on
    std::pair<edge_iterator, edge_iterator> ei = edges(g);
    for(edge_iterator edge_iter = ei.first; edge_iter != ei.second; ++edge_iter) {
        std::cout << "(" << source(*edge_iter, g) << ", " << target(*edge_iter, g) << ")\n";
    }

    std::cout << "\n";
    //Want to add another edge between (A,E)?
    add_edge(A, E, g);

    //Print out the edge list again to see that it has been added
    for(edge_iterator edge_iter = ei.first; edge_iter != ei.second; ++edge_iter) {
        std::cout << "(" << source(*edge_iter, g) << ", " << target(*edge_iter, g) << ")\n";
    }

    //Finally lets add a new vertex - remember the verticies are just of type int
    int F = add_vertex(g);
    std::cout << F << "\n";

    //Connect our new vertex with an edge to A...
    add_edge(A, F, g);

    //...and print out our edge set once more to see that it was added
    for(edge_iterator edge_iter = ei.first; edge_iter != ei.second; ++edge_iter) {
        std::cout << "(" << source(*edge_iter, g) << ", " << target(*edge_iter, g) << ")\n";
    }
    return 0;
}*/


#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/boykov_kolmogorov_max_flow.hpp>
#include <boost/graph/read_dimacs.hpp>
#include <boost/graph/graph_utility.hpp>

using namespace boost;

typedef adjacency_list_traits < vecS, vecS, directedS > Traits;
typedef adjacency_list < vecS, vecS, directedS,
  property < vertex_name_t, std::string,
  property < vertex_index_t, long,
  property < vertex_color_t, boost::default_color_type,
  property < vertex_distance_t, long,
  property < vertex_predecessor_t, Traits::edge_descriptor > > > > >,

  property < edge_capacity_t, long,
  property < edge_residual_capacity_t, long,
  property < edge_reverse_t, Traits::edge_descriptor > > > > Graph;

struct Temp{
     Graph g;
     property_map < Graph, edge_capacity_t >::type          capacity ;
     property_map < Graph, edge_residual_capacity_t >::type residual_capacity ;
     property_map < Graph, edge_reverse_t >::type rev;
     Traits::vertex_descriptor s, t;
     vector<Traits::vertex_descriptor> verts;


     Temp (int vn): g(vn), capacity(get(edge_capacity, g)), rev(get(edge_reverse, g)), residual_capacity(get(edge_residual_capacity, g)) {
          fori (i, vn) verts << add_vertex(g);
     }

     void add_edge_int(int i, int j) {
          if (i == 0 && j == 1)
               abort();
          Traits::edge_descriptor e1, e2;
          bool in1, in2;
          boost::tie(e1, in1) = boost::add_edge(verts[i], verts[j], g);
          boost::tie(e2, in2) = boost::add_edge(verts[j], verts[i], g);

          capacity[e1] = 1;
          capacity[e2] = 0;
          rev[e1] = e2;
          rev[e2] = e1;
     }
     void add_edge(int i, int j) {
          add_edge_int(i,j);
          add_edge_int(j,i);
     }

     int vid(const Traits::vertex_descriptor& v, const vector<vector<int> >& ids){
          fori (i, verts.size()) if (verts[i] == v) return i;
          return -1;
     }
};

void fieldcon(const vector<vector<bool> >& map, const vector<vector<int> > &ids, Temp& t, int i, int j, int d, int e){
     if (i+d < 0 || i+d >= map.size()) return;
     if (j+e < 0 || j+e >= map[0].size()) return;
     if (!map[i+d][j+e]) return;
     t.add_edge_int(ids[i][j] + 1, ids[i+d][j+e]);
     t.add_edge_int(ids[i+d][j+e] + 1, ids[i][j]);
}

int calcflow(int w, int h, const vector<vector<bool> >& map){
     vector<vector<int> > ids;
     ids.resize(w);
     int id = 2;
     fori (i, w) {
          ids[i].resize(h);
          fori (j, h) {
               if (map[i][j]) { ids[i][j] = id; id += 2 ; }
               else ids[i][j] = -1;
          }
     }

     Temp g(id);


     fori (j, h) {
          if (map[0][j]) g.add_edge_int(0, ids[0][j]);
          if (map[w-1][j]) g.add_edge_int(ids[w-1][j]+1, 1);
          fori (i, w) g.add_edge_int(ids[i][j], ids[i][j]+1);
     }

     fori (i, w) {
          ids[i].resize(h);
          fori (j, h) {
               if (!map[i][j]) continue;
           //    fieldcon(map, ids, g, i, j, -1, 0);
               fieldcon(map, ids, g, i, j, 1, 0);
           //    fieldcon(map, ids, g, i, j, 0, -1);
               fieldcon(map, ids, g, i, j, 0, 1);
          }
     }


    //  read_dimacs_max_flow(g, capacity, rev, s, t);

   //  std::vector<default_color_type> color(num_vertices(g));
   //  std::vector<long> distance(num_vertices(g));
     long flow = boykov_kolmogorov_max_flow(g.g ,g.verts[0], g.verts[1]);

   /*
     std::cout << "ids" << endl;
     fori (j, h) {
          fori (i, w) {
               printf("%d\t", ids[i][h-1-j]);
          }
          printf("\n");
     }


     std::cout << "c flow values:" << std::endl;
     graph_traits < Graph >::vertex_iterator u_iter, u_end;
     graph_traits < Graph >::out_edge_iterator ei, e_end;
     for (tie(u_iter, u_end) = vertices(g.g); u_iter != u_end; ++u_iter)
       for (tie(ei, e_end) = out_edges(*u_iter, g.g); ei != e_end; ++ei)
         if (g.capacity[*ei] > 0)
             std::cout << "f " << g.vid(*u_iter, ids) << " " << g.vid(target(*ei, g.g), ids) << " "
             << (g.capacity[*ei] - g.residual_capacity[*ei]) << std::endl;
*/
  //   std::cout << "c  The total flow:" << std::endl;
  //   std::cout << "s " << flow << std::endl << std::endl;
     return flow;
}

int main(int argc, char *argv[])
{




     int T;
     scanf("%i", &T);
     forr (tt, 1, T) {
          int w,h,b;
          scanf("%i %i %i\n", &w, &h, &b);
          vector<vector<bool> > map;
          map.resize(w);
          fori (i, w) {
               map[i].resize(h, true);
          }

          fori (i,b) {
               int x0, y0, x1, y1;
               scanf("%i %i %i %i\n", &x0, &y0, &x1, &y1);
               forr (x, x0, x1)
                         forr (y, y0, y1)
                              map[x][y] = false;
          }

          int flow = calcflow(w, h, map);


          printf("Case #%i: %i\n", tt, flow);
          //printf("%i %i\n", deceiveScore, warScore);
     }
}
