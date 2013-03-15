assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Jade Multiple', ->
    before (done) ->
        options =
            path: 'src'
            wait: true
            pack: ['jadevu']
        common.compile 'jade_multiple', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/jade_multiple/public/js/jade_multiple.bundle.js'))

    it 'Compiles to a minified JS file', ->
        assert(fs.existsSync('tmp/jade_multiple/public/js/jade_multiple.bundle.min.js'))

    it 'Contains the Jade templates', (done) ->
        common.execute 'jade_multiple', 'index', (vars) ->
            assert(vars.result.success)
            assert.equal(vars.result.jade, '<h1>Test</h1>')
            assert.equal(vars.result.jade2, '<h1>Test 2</h1>')
            done()

    it 'Contains the minified Jade templates', (done) ->
        common.executeMin 'jade_multiple', 'index', (vars) ->
            assert(vars.result.success)
            assert.equal(vars.result.jade, '<h1>Test</h1>')
            assert.equal(vars.result.jade2, '<h1>Test 2</h1>')
            done()

