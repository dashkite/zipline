import Repos from "./repos"
import Graph from "./graph"

export default sort = ( root, { flatten }) ->

  directories = Repos.discover root
  packages = Repos.packages root, directories
  dependencies = Repos.dependencies packages

  layers = []
  pending = new Set Object.keys dependencies
  cycle = false
  while pending.size > 0
    ( layer = [] ) unless cycle
    length = layer.length
    for name from pending
      satisfied = 
        dependencies[ name ]
          .every ( node ) ->
            !( pending.has node )
      if satisfied
        layer.push name
    if layer.length == length
      cycle = true
      layer.push do ->
        ( Graph.cyclesFrom dependencies, Array.from pending ).at 0
    else if cycle
      cycle = false
      layers.push layer[0...length]
      layers.push layer[length..]
    else
      layers.push layer
    for name in layer
      pending.delete name
  
  result = layers
    .map ( layer ) ->
      layer
        .map ( name ) -> 
          packages[ name ].directory

  if flatten
    [ result.flat() ]
  else
    result