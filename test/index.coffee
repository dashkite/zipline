import path from "node:path"
import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import sort from "../src/sort"
import scenarios from "./scenarios"

_sort = ( scenario ) ->
  sort ( path.join __dirname, "fixtures", scenario ), {}

verify = ( scenario ) -> ->
  assert.deepEqual scenarios[ scenario ], _sort scenario

do ->

  print await test "zipline", [
    test "works with a simple linear dependency", verify "linear"
    test "works with a diamond dependency", verify "diamond"
    test "works with no dependencies", verify "independent"
    test "works despite cyclic dependencies", verify "cycle"
  ]

  process.exit if success then 0 else 1

