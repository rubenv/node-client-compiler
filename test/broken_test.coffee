assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Broken', ->
    it 'Warns for broken CoffeeScript files', (done) ->
        options =
            path: 'src'
        common.compileBundle 'broken', options, (err) ->
            assert.notEqual(err, null)
            done()

    it 'Warns for broken CoffeeScript files when minifying', (done) ->
        options =
            path: 'src'
        common.compileMin 'broken', options, (err) ->
            assert.notEqual(err, null)
            done()
