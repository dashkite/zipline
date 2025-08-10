import FS from "node:fs"
import Path from "node:path"
import * as Graph from "./graph"

Repos =

  isModule: ( path ) ->
    (( FS.statSync path  ).isDirectory() &&
      ( FS.existsSync Path.join path, "package.json" ))

  discover: ( path ) ->
    FS
      .readdirSync path
      .filter ( name ) -> 
        Repos.isModule Path.join path, name

  packages: ( root, directories ) ->

    result = {}

    for directory in directories
      path = Path.join root, directory, "package.json"
      data = JSON.parse FS.readFileSync path, "utf8"
      result[ data.name ] = { directory, data }

    result

  dependencies: ( packages ) ->

    result = {}
    names = Object.keys packages

    for name, { data } of packages
      dependencies = [
        ( Object.keys data.dependencies ? {} )...
        ( Object.keys data.devDependencies ? {} )...
      ]
      result[ name ] = dependencies.filter ( name ) -> name in names

    result

export default sort = ( root, roots ) ->

  directories = Repos.discover root
  packages = Repos.packages root, directories
  dependencies = Repos.dependencies packages

  dependents = do ({ node, edges } = {}) ->
    ( graph, target ) ->
      new Set do ->
        node for node, edges of graph when target in edges

  if roots?
    roots = roots
      .map ( name ) ->
        Object
          .values packages
          .find ({ directory }) -> directory == name
          ?.data
          ?.name
      .filter ( name ) -> name?
  else
    roots = []
    length = 0
    while roots.length == 0
      roots = (node for node, edges of dependencies when edges.length == length)
      length++

  layers = []
  layer = new Set roots
  visited = new Set
  while layer.size > 0
    current = new Set
    for node from layer when !visited.has node
      visited.add node
      current = current.union dependents dependencies, node
    current = current.difference visited
    layers.push layer
    layer = current

  result = 
    layers
      .map ( layer ) ->
        ( Array.from layer )
          .map ( name ) -> 
            packages[ name ].directory

  result
