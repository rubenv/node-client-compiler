vm = require 'vm'
fs = require 'fs'
path = require 'path'

clientCompile = require '..'

createCompiler = (name, config) ->
    basePath = path.join(__dirname, '../tmp/', name)
    return new clientCompile.Compiler(basePath, name, config)

common = module.exports =
    compile: (name, config, cb) ->
        createCompiler(name, config).compile(cb)

    compileBundle: (name, config, cb) ->
        createCompiler(name, config).compile(cb)

    compileMin: (name, config, cb) ->
        createCompiler(name, config).compile(cb)

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
