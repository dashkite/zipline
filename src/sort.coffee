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

  dependencies: ( names, root ) ->

    repos = new Set
    dependencies = {}
    _packages = {}

    # first, initialize the repos set with the package names
    # and the _packages dictionary with descriptors
    # containing the repo name and the package

    # the package names are not necessarily the same as the
    # repo names, which are just directory names
    
    for name in names
      path = Path.join root, name, "package.json"
      _package = JSON.parse FS.readFileSync path, "utf8"
      _packages[ _package.name ] =
        repo: name
        package: _package
      repos.add _package.name

    # next, collect the aggregate dependencies for each
    # package (including both production and development
    # dependencies) filtering out any that aren't in our
    # repos set

    for name, { package: _package } of _packages
      _dependencies = [
        ( Object.keys _package.dependencies ? {} )...
        ( Object.keys _package.devDependencies ? {} )...
      ]
      dependencies[ name ] =
        _dependencies.filter ( dependency ) -> repos.has dependency

    # return our dependency and package dictionaries
    # (we could consolidate these, but it will be convenient later
    # to keep the dependencies dictionary separate)    
    { dependencies, packages: _packages }

  sort: ({ dependencies, packages: _packages }) ->

    # our dependencies dictionary also serves as a representation
    # of the dependency graph

    # decycle the graph
    _dependencies = Graph.decycle dependencies

    # place all the dependency names into a pending set
    # representing all the packages whose dependencies have
    # not yet been satisfied

    pending = new Set Object.keys dependencies

    # we'll return an array of "layers" representing the poset
    layers = []

    # loop through the pending set until all packages have been
    # placed into a layer
    while pending.size > 0

      # initialize the current layer that we're going to build up
      layer = []

      # go through the pending set
      for repo from pending

        # for each repo see whether or not all of its dependencies
        # have been satisfied and, if so, add it to the layer

        satisfied =
          _dependencies[ repo ]
            .every ( dependency ) -> 
              !pending.has dependency
        
        layer.push _packages[ repo ] if satisfied

      # once we've finished a given pass, save the layer

      # we don't need to check if its empty because we've
      # removed all the cycles already

      layers.push layer

      # remove the satisifed repos from the pending set
      for { package: _package } in layer
        pending.delete _package.name      

    # return layers which is our poset
    layers

export default sort = ( path ) ->
  repos = Repos.discover path
  packages = Repos.dependencies repos, path

  # distill the repo names from the layers, which contain the
  # full package descriptors (repo name and package data)
  Repos.sort packages
    .map ( layer ) ->
        layer.map ({ repo }) -> repo