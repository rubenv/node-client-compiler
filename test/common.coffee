vm = require 'vm'
fs = require 'fs'
path = require 'path'

clientCompile = require '..'

common = module.exports =
    compile: (name, config, cb) ->
        basePath = path.join(__dirname, '../tmp/', name)
        compiler = new clientCompile.Compiler(basePath, name, config)
        compiler.compile(cb)

    execute: (name, entry, cb) ->
        common.executePath('tmp/' + name + '/public/js/' + name + '.bundle.js', entry, cb)

    executeMin: (name, entry, cb) ->
        common.executePath('tmp/' + name + '/public/js/' + name + '.bundle.min.js', entry, cb)

    executePath: (path, entry, cb) ->
        vars = { result: {} }
        context = vm.createContext(vars)
        vm.runInContext(fs.readFileSync(path, 'utf8'), context)
        vm.runInContext("require('#{entry}');", context)
        cb(vars)
