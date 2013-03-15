assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Jade', ->
    before (done) ->
        options =
            path: 'src'
            wait: true
            pack: ['jadevu']
        common.compile 'jade', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/jade/public/js/jade.bundle.js'))

    it 'Compiles to a minified JS file', ->
        assert(fs.existsSync('tmp/jade/public/js/jade.bundle.min.js'))

    it 'Contains the Jade template', (done) ->
        common.execute 'jade', 'index', (vars) ->
            assert(vars.result.success)
            assert.equal(vars.result.jade, '<h1>Test</h1>')
            done()

    it 'Contains the minified Jade template', (done) ->
        common.executeMin 'jade', 'index', (vars) ->
            assert(vars.result.success)
            assert.equal(vars.result.jade, '<h1>Test</h1>')
            done()
