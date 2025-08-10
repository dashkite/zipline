# given a (directed) graph and a node, count the dependent nodes
# (nodes with an path back to the given node)

dependents = do ( caches = new Map ) ->
  ( graph, target, start, visited = new Set ) ->
    if !( caches.has graph )
      caches.set graph, {}
    cache = caches.get graph
    cache[ target ] ?= do ->
      visited.add target
      start ?= target
      result = new Set
      for node, edges of graph
        if ( node != target ) && ( node != start )
          if ( target in edges )
            result.add node
            if !( visited.has node )
              result = result.union dependents graph, node, start, visited
      result
  
# given a graph and a target node, determine whether there's 
# path from the target back to itself (a cycle)

# optionally takes a starting node which defaults to the target
# and a set of visited nodes

# these optional arguments are used for recursive calls

hasCycle = ( graph, target, start, visited = new Set ) ->
  start ?= target
  if visited.has start
    false
  else if target in graph[ start ]
    true
  else
    visited.add start
    graph[ start ].some ( edge ) -> 
      hasCycle graph, target, edge, visited

# given a graph, remove cycles from the graph

# prioritize nodes withe more dependents in an attempt 
# to remove edges from leaf nodes rather than roots

decycle = ( graph ) ->
  result = {}
  visited = new Set
  entries = Array
    .from Object.entries graph
    .sort ([ a ], [ b ]) -> 
      ( dependents graph, a ) - ( dependents graph, b )
  for [ node, edges ] in entries
    if hasCycle graph, node
      visited.add node
    result[ node ] =
      edge for edge in edges when !( visited.has edge )
  result

export  { dependents, decycle }