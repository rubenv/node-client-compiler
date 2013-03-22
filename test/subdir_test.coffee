assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Subdir', ->
    before (done) ->
        options =
            path: 'src'
        common.compileBundle 'subdir', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/subdir/public/js/subdir.bundle.js'))

    it 'Contains the source code', (done) ->
        common.execute 'subdir', 'index', (vars) ->
            assert(vars.result.index)
            assert(vars.result.second)
            done()
