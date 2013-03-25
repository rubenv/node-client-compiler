assert = require 'assert'
common = require './common'
fs = require 'fs'

describe.only 'Skip Header', ->
    before (done) ->
        options =
            path: 'src'
            skipHeader: true
        common.compileBundle 'skip_header', options, done

    it 'Compiles to a JS file', ->
        assert(fs.existsSync('tmp/skip_header/public/js/skip_header.bundle.js'))

    it 'Does not contain the require wrapper', ->
        assert.throws () ->
            common.execute 'skip_header', 'index', (vars) ->
