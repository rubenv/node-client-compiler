assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Library', ->
    before (done) ->
        options =
            path: 'src'
            pack: [ 'someLibrary', 'secondLibrary' ]
        common.compile 'library', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/library/public/js/library.bundle.js'))

    it 'Compiles to a minified JS file', ->
        assert(fs.existsSync('tmp/library/public/js/library.bundle.min.js'))

    it 'Contains the source code', (done) ->
        common.execute 'library', 'index', (vars) ->
            assert(vars.result.success)
            assert(vars.result.library)
            assert(vars.result.library2)
            done()

    it 'Contains the minified source code', (done) ->
        common.executeMin 'library', 'index', (vars) ->
            assert(vars.result.success)
            assert(vars.result.library)
            done()

    it 'Reuses the minified library, if present', (done) ->
        common.executeMin 'library', 'index', (vars) ->
            assert(vars.result.success)
            assert(vars.result.library)
            assert(vars.result.library2Min)
            assert.equal(vars.result.library2, null)
            done()
