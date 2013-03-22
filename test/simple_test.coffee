assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Simple', ->
    before (done) ->
        options =
            path: 'src'
        common.compile 'simple', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/simple/public/js/simple.bundle.js'))

    it 'Compiles to a minified JS file', ->
        assert(fs.existsSync('tmp/simple/public/js/simple.bundle.min.js'))

    it 'Contains the source code', (done) ->
        common.execute 'simple', 'index', (vars) ->
            assert(vars.result.success)
            done()

    it 'Contains the minified source code', (done) ->
        common.executeMin 'simple', 'index', (vars) ->
            assert(vars.result.success)
            done()
