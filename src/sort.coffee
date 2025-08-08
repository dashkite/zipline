import FS from "node:fs"
import Path from "node:path"
import * as Graph from "./graph"

Repos =

  isRepo: ( path ) ->
    (( FS.statSync path  ).isDirectory() &&
      ( FS.existsSync Path.join path, "package.json" ))

  discover: ( path ) ->
    FS
      .readdirSync path
      .filter ( name ) -> 
        Repos.isRepo Path.join path, name

  dependencies: ( names, root ) ->

    repos = new Set
    dependencies = {}
    _packages = {}

    for name in names
      path = Path.join root, name, "package.json"
      _package = JSON.parse FS.readFileSync path, "utf8"
      _packages[ _package.name ] =
        repo: name
        package: _package
      repos.add _package.name

    for name, { package: _package } of _packages
      _dependencies = [
        ( Object.keys _package.dependencies ? {} )...
        ( Object.keys _package.devDependencies ? {} )...
      ]
      dependencies[ name ] =
        _dependencies.filter ( dependency ) -> repos.has dependency
    
    { dependencies, packages: _packages }

  sort: ({ dependencies, packages: _packages }) ->
    _dependencies = Graph.decycle dependencies
    pending = new Set Object.keys dependencies
    layers = []
    while pending.size > 0
      layer = []
      for repo from pending
        satisfied =
          _dependencies[ repo ]
            .every ( dependency ) -> 
              !pending.has dependency
        layer.push _packages[ repo ] if satisfied
      if layer.length > 0
        layers.push layer
      for { package: _package } in layer
        pending.delete _package.name      
    layers

export default sort = ( path ) ->
  repos = Repos.discover path
  packages = Repos.dependencies repos, path
  Repos.sort packages
    .map ( layer ) ->
        layer.map ({ repo }) -> repo