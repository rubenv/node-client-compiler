assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Plain', ->
    before (done) ->
        options =
            path: 'src'
        common.compileBundle 'plain', options, done

    it 'Embeds plain JS code', (done) ->
        common.execute 'plain', 'index', (vars) ->
            assert(vars.result.success)
            done()
