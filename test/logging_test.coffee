assert = require 'assert'
common = require './common'
fs = require 'fs'

describe 'Logging', ->
    messages = []

    before (done) ->
        options =
            path: 'src'
            verbose: true
            pack: [ 'someLibrary' ]
            logCb: (verb, message) ->
                messages.push
                    verb: verb
                    message: message
        common.compile 'logging', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/logging/public/js/logging.bundle.js'))

    it 'Logs the CoffeeScript compilation', ->
        assert.equal(messages[0].verb, 'create')
        assert.equal(messages[0].message, 'tmp/js/logging.js')

    assertMessage = (verb, message) ->
        found = false
        for pair in messages
            found = true if pair.verb == verb && pair.message == message
        assert found, "Did not find log message: #{verb}: #{message}"

    it 'Logs the main source bundling', ->
        assertMessage('bundle', 'public/js/logging.bundle.js')

    it 'Logs the library minification', ->
        assertMessage('minify', 'tmp/js/someLibrary.min.js')

    it 'Logs the CoffeeScript minification', ->
        assertMessage('minify', 'tmp/js/logging.min.js')

    it 'Logs the minified source bundling', ->
        assertMessage('bundle', 'public/js/logging.bundle.min.js')
