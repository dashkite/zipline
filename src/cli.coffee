import FS from "node:fs"
import { Command } from "commander"
import YAML from "yaml"
import sort from "./sort"

program = new Command
program
  .name "zipline"
  .description "Output layered topological sort of local NPM repos as YAML"
  .argument "<path>", "Directory containing repos"
  .option "-o, --output <file>", "Output file (defaults to stdout)"
  .option "-d, --directories <directories>", 
    "Entry points for the dependency graph.
      Multiple directories may be separated by '+'.",
    ( value ) -> value.split "+"
  .version "1.0.0"

program.parse process.argv
options = program.opts()
path = program.args[0]

try
  layers = sort path, options.directories
  yaml = YAML.stringify layers
  if options.output
    FS.writeFileSync options.output, yaml
  else
    console.log yaml
catch error
  console.error "Error: #{error.message}"
  process.exit 1