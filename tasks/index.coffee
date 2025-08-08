import FS from "node:fs/promises"
import * as Genie from "@dashkite/genie"

# TODO incorporate into preset
Genie.define "bin", ->
  await FS.mkdir "build/node/src/bin", recursive: true
  FS.copyFile "src/bin/zipline", "build/node/src/bin/zipline"

Genie.after "build", "bin"