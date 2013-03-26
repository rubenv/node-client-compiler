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

    it 'Logs the main source bundling', ->
        assert.equal(messages[1].verb, 'bundle')
        assert.equal(messages[1].message, 'public/js/logging.bundle.js')

    it 'Logs the library minification', ->
        assert.equal(messages[2].verb, 'minify')
        assert.equal(messages[2].message, 'tmp/js/someLibrary.min.js')

    it 'Logs the CoffeeScript minification', ->
        assert.equal(messages[3].verb, 'minify')
        assert.equal(messages[3].message, 'tmp/js/logging.min.js')

    it 'Logs the minified source bundling', ->
        assert.equal(messages[4].verb, 'bundle')
        assert.equal(messages[4].message, 'public/js/logging.bundle.min.js')
