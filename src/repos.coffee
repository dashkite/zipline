import FS from "node:fs"
import Path from "node:path"

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

export default Repos