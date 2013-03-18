assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Broken', ->
    it 'Warns for broken CoffeeScript files', (done) ->
        options =
            path: 'src'
        common.compile 'broken', options, (err) ->
            assert.notEqual(err, null)
            done()

