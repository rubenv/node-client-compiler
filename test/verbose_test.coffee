assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Verbose', ->
    it 'Outputs messages when verbose is set', (done) ->
        messages = []

        options =
            path: 'src'
            verbose: true
            logCb: (verb, message) ->
                messages.push
                    verb: verb
                    message: message
        common.compileBundle 'simple', options, (err) ->
            return done(err) if err
            assert(messages.length > 0)
            done()

    it 'Does not Output messages when verbose is not set', (done) ->
        messages = []

        options =
            path: 'src'
            verbose: false
            logCb: (verb, message) ->
                messages.push
                    verb: verb
                    message: message
        common.compileBundle 'simple', options, (err) ->
            return done(err) if err
            assert.equal(messages.length, 0)
            done()
