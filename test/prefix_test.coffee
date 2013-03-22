assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Prefix', ->
    before (done) ->
        options =
            requirePrefix: 'test/'
            path: 'src'
        common.compileBundle 'prefix', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/prefix/public/js/prefix.bundle.js'))

    it 'Adds a prefix to the module name', (done) ->
        common.execute 'prefix', 'test/index', (vars) ->
            assert(vars.result.success)
            done()
