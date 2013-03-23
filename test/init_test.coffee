assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Init', ->
    before (done) ->
        options =
            path: 'src'
            initWith: 'init'
        common.compileBundle 'init', options, done

    it 'Allows for an initWith option', (done) ->
        common.execute 'init', (vars) ->
            assert(vars.result.success)
            done()
