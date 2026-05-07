+++
date = '2026-05-06T14:41:22+08:00'
draft = false
title = '计算系统期中cheating sheet分享'
categories = ['课程笔记']
tags = ['计算系统','学习笔记']
+++

# Computing System Midterm

<style>
@page {
  size: A4 portrait;
  margin: 7mm 7mm 7mm 7mm;
}

html,
body {
  margin: 0 !important;
  padding: 0 !important;
  font-size: 14px !important;
  line-height: 1.28 !important;
}

body {
  column-count: 2;
  column-gap: 6mm;
}

p {
  margin: 5px 0 8px !important;
  font-weight: 700;
  break-after: avoid;
}

pre,
pre.hljs,
pre:not(.hljs) {
  margin: 4px 0 9px !important;
  padding: 7px 8px !important;
  border-width: 0.5px !important;
  border-radius: 2px !important;
  overflow: visible !important;
  white-space: pre-wrap !important;
  overflow-wrap: anywhere !important;
  break-inside: auto;
  page-break-inside: auto;
}

.keep-next {
  display: block;
  height: 0;
  margin: 0;
  padding: 0;
  break-after: avoid;
}

.keep-next + pre,
pre.keep {
  break-inside: avoid !important;
  page-break-inside: avoid !important;
}

code,
pre code,
pre.hljs code {
  font-family: Consolas, "Courier New", monospace !important;
  font-size: 11.8px !important;
  line-height: 1.22 !important;
}
</style>

## implement
注：全部是1-based
```cpp
bool toposort(int n, vector<vector<int>>& adj, vector<int>& order) {
    vector<int> indeg(n+1); 
    queue<int> q; 
    order.clear();
    for (int u = 1; u <= n; u++) 
        for (int v : adj[u]) indeg[v]++;
    for (int i = 1; i <= n; i++) 
        if (!indeg[i]) q.push(i);
    while (!q.empty()) {
        int u = q.front(); q.pop(); 
        order.push_back(u);
        for (int v : adj[u]) 
            if (--indeg[v] == 0) q.push(v);
    }
    return order.size() == n; // false: cycle
}
```
```cpp
//quick power
long long qpow(long long a, long long k) {
    long long res = 1;
    while (k > 0) {
        if (k & 1) res = res * a % MOD;
        a = a * a % MOD;
        k >>= 1;
    }
    return res;
}
// res 不能初始化成 a，否则 K=1 时会算成 a^2。
```

## SCC
```cpp
// kosaraju, 1-based
vector<vector<int>> adj(n+1),adjinv(n+1), scc(1);
vector<int> visited(n+1), post_order, scc_temp, scc_index(n+1,-1);
void DFS1(int u){
    visited[u]=1; 
    for(int v:adj[u]) if(!visited[v]) DFS1(v); 
    post_order.push_back(u);}
void DFS2(int u){
    visited[u]=1; scc_temp.push_back(u); 
    for(int v:adjinv[u]) if(!visited[v]) DFS2(v);}
void kosaraju(int n){
    post_order.clear(); scc.clear(); 
    scc.push_back({}); scc_index.assign(n+1,-1);
    visited.assign(n+1,0); 
    for(int i=1;i<=n;i++) {
        if(!visited[i]) DFS1(i);}
    visited.assign(n+1,0);
    for(int i=post_order.size()-1;i>=0;i--) 
        if(!visited[post_order[i]]){
            scc_temp.clear(); 
            DFS2(post_order[i]); 
            scc.push_back(scc_temp);
            for(int x:scc_temp) 
                scc_index[x]= scc.size()-1;
        }
}
// SCC用途：缩点成DAG+dp
// 连边：if(scc_index[u]!=scc_index[v]) 
// scc_adj[scc_index[u]].push_back(scc_index[v]);
// 去重：每个v在DAG:sort(v.begin(),v.end()); 
// v.erase(unique(v.begin(),v.end()),v.end());
// DP：toposort+ dp[v]=max(dp[v], dp[u]+weight[v])
```
## shortest path
```cpp
struct Edge{int u,v,w;};
const long long INF = (1LL<<60);
```
```cpp
// Bellman-Ford: 有负权, 边集, 1-based
vector<Edge> edge(m); vector<long long> dist(n+1, INF);
dist[s]=0;
for(int i=0;i<=n;i++) 
    for(auto e:edge)
        if(dist[e.u]!=INF 
        && dist[e.u]+e.w<dist[e.v]) 
            dist[e.v]=dist[e.u]+e.w;
// neg cycle reachable from s:
for(auto e:edge) 
    if(dist[e.u]!=INF 
    && dist[e.u]+e.w<dist[e.v]) {/* has neg cycle */}
//最短路数量 init: cnt[s]=1; last[u][v]=0  // paths already contributed from u to v
// if nd<dist[v]: cnt[v]=cnt[u]; clear last[*][v]; last[u][v]=cnt[u]
// else if nd==dist[v]: cnt[v]+=cnt[u]-last[u][v]; last[u][v]=cnt[u]
```
```cpp
// Dijkstra: 无负权, 邻接表adj[u] = {v,w}, 1-based
vector<vector<pair<int,int>>> adj(n+1);
vector<long long> dist(n+1,INF);
priority_queue<pair<long long,int>, vector<pair<long long,int>>,
 greater<pair<long long,int>>> pq;
dist[s]=0; pq.push({0,s});
while(!pq.empty()){
    auto [d,u]=pq.top(); pq.pop();
    if(d!=dist[u]) continue; // 过期
    for(auto [v,w]:adj[u]){
        if(d+w<dist[v]) {
            dist[v]=d+w;pq.push({dist[v],v});}
    }
}
// 最短路数量：正权图中可同步维护 cnt
// init: cnt[s]=1
// if dist[u]+w < dist[v]: dist[v]=dist[u]+w; cnt[v]=cnt[u]; push(v)
// else if dist[u]+w == dist[v]: cnt[v]=(cnt[v]+cnt[u])%MOD
```
```cpp
//Floyd：任意两点最短路, n小, O(n^3)
vector<vector<long long>> dist(n+1, vector<long long>(n+1, INF));
for(int i=1;i<=n;i++) dist[i][i]=0;
for(auto e:edge) dist[e.u][e.v]=min(dist[e.u][e.v], (long long)e.w);
for(int k=1;k<=n;k++)
    for(int i=1;i<=n;i++)
        for(int j=1;j<=n;j++)
            if(dist[i][k]!=INF && dist[k][j]!=INF)
                dist[i][j]=min(dist[i][j], dist[i][k]+dist[k][j]);
```

## minimum spanning tree
```cpp
// Prim: 任意起点, 邻接表, check cnt==n
vector<vector<pair<int,int>>> adj(n+1);//{v,w}
priority_queue<pair<int,int>, vector<pair<int,int>>, greater<pair<int,int>>> pq; // {w,v}
vector<int> visited(n+1); long long cost=0; int cnt=0;
pq.push({0,1});
while(!pq.empty()){
    auto [w,u]=pq.top(); pq.pop();
    if(visited[u]) continue;
    visited[u]=1; cost+=w; cnt++;
    for(auto [v,nw]:adj[u]) 
        if(!visited[v]) pq.push({nw,v});
}
// cnt<n: graph disconnected
```
<span class="keep-next"></span>

```cpp
// Kruskal: 稀疏图, DSU, check cnt==n-1
struct Edge{int u, v, w;};
vector<Edge> edge(m); vector<int> parent(n+1), sz(n+1,1);
long long cost=0; int cnt=0;
for(int i=1;i<=n;i++) parent[i]=i;
sort(edge.begin(),edge.end(),[](Edge a,Edge b){return a.w<b.w;});
int find(int x){
    return parent[x]==x?x:parent[x]=find(parent[x]);}
for(const auto &e:edge){
    int rootu=find(e.u), rootv=find(e.v);
    if(rootu!=rootv){
        if(sz[rootu]<sz[rootv]) swap(rootu,rootv);
        parent[rootv]=rootu; sz[rootu]+=sz[rootv]; 
        cost+=e.w; cnt++;
    }
}
// cnt<n-1: graph disconnected
```