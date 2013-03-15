vm = require 'vm'
fs = require 'fs'
path = require 'path'

clientCompile = require '..'

module.exports =
    compile: (name, config, cb) ->
        basePath = path.join(__dirname, '../tmp/', name)
        compiler = new clientCompile.Compiler(basePath, name, config)
        compiler.compile(cb)

    execute: (name, entry, cb) ->
        vars = { result: {} }
        context = vm.createContext(vars)
        vm.runInContext(fs.readFileSync('tmp/' + name + '/public/js/' + name + '.bundle.js', 'utf8'), context)
        vm.runInContext("require('#{entry}');", context)
        cb(vars)

    executeMin: (name, entry, cb) ->
        vars = { result: {} }
        context = vm.createContext(vars)
        vm.runInContext(fs.readFileSync('tmp/' + name + '/public/js/' + name + '.bundle.min.js', 'utf8'), context)
        vm.runInContext("require('#{entry}');", context)
        cb(vars)
