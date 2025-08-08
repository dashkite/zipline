# Zipline

_Generate a topological sort for the repos in a directory_

## Installation

Use your favorite package installer.

## Usage

```sh
zipline <path> [--output <file>]
```

- `<path>`: Path to a directory of repos.
- `--output <file>`: Write output to file instead of stdout.

## Output Format

The output is YAML containing an array of arrays, or _layers_. Each layer contains the directory names for the corresponding repo.

Each layer may be processed in order. The repos within a layer may be processed in parallel.