assert = require 'assert'
common = require './common'

describe 'Empty', ->
    it 'Compiles an empty source dir', (done) ->
        options =
            path: 'src'
        common.compileBundle 'empty', options, (err) ->
            assert.equal(err, null)
            done()
