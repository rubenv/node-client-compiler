assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Paths', ->
    before (done) ->
        options =
            path: 'app-src'
            tmpPath: 'tmp'
            libPath: 'lib'
            outPath: 'out'
            pack: [ 'someLibrary', 'secondLibrary' ]
        common.compile 'paths', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/paths/out/paths.bundle.js'))

    it 'Compiles to a minified JS file', ->
        assert(fs.existsSync('tmp/paths/out/paths.bundle.min.js'))

    it 'Uses the correct tmp path', ->
        assert(fs.existsSync('tmp/paths/tmp/paths.js'))
        assert(fs.existsSync('tmp/paths/tmp/paths.min.js'))

    it 'Contains the source code', (done) ->
        common.executePath 'tmp/paths/out/paths.bundle.js', 'index', (vars) ->
            assert(vars.result.success)
            assert(vars.result.library)
            assert(vars.result.library2)
            done()

    it 'Contains the minified source code', (done) ->
        common.executePath 'tmp/paths/out/paths.bundle.min.js', 'index', (vars) ->
            assert(vars.result.success)
            assert(vars.result.library)
            done()

    it 'Reuses the minified library, if present', (done) ->
        common.executePath 'tmp/paths/out/paths.bundle.min.js', 'index', (vars) ->
            assert(vars.result.success)
            assert(vars.result.library)
            assert(vars.result.library2Min)
            assert.equal(vars.result.library2, null)
            done()
