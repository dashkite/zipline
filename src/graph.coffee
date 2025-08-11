Graph =

  dependents: do ({ node, edges } = {}) ->
    ( graph, target ) ->
      new Set do ->
        node for node, edges of graph when target in edges

  closure: do ({ result, visited, previous, node } = {}) ->
    ( graph, start ) ->
      result = new Set graph[ start ]
      visited = new Set [ start ]
      previous = 0
      while result.size > previous
        previous = result.size
        for node from result when !( visited.has node )
          result = result.union new Set graph[ node ]
      result

  cycle: ( graph, target ) ->
    ( Graph.closure graph, target ).has target
      
  cyclesFrom: ( graph, targets ) ->
    targets
      .sort ( a, b ) ->
        ( Graph.dependents graph, b ).size -
          ( Graph.dependents graph, a ).size
      .filter ( name ) -> Graph.cycle graph, name

export default Graph