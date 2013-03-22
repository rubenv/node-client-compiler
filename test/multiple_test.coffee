assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Multiple', ->
    before (done) ->
        options =
            path: 'src'
        common.compileBundle 'multiple', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/multiple/public/js/multiple.bundle.js'))

    it 'Contains the source code', (done) ->
        common.execute 'multiple', 'index', (vars) ->
            assert(vars.result.index)
            assert(vars.result.second)
            done()
