fort = require 'fort'
async = require 'async'
closure = require 'closure-compiler'
coffee = require 'coffee-script'
walkdir = require 'walkdir'
fs = require 'fs'
jade = require 'jade'
mkdirp = require 'mkdirp'
path = require 'path'

require 'jadevu'

browser =
    # Require a module.
    require: (p) ->
        mod = require.modules[p]
        throw new Error("failed to require \"" + p + "\"") unless mod
        if !mod.exports
            mod.exports = {}
            mod.call mod.exports, mod, mod.exports, require
        mod.exports
    
    # Register a module
    register: (path, fn) ->
        require.modules[path] = fn

runTask = (task, cb) -> task.exec cb
minifier = async.queue runTask, 2

class SourceFile
    constructor: (@compileUnit, @fileName) ->
        @output = ''

        prefix = @compileUnit.compiler.options.requirePrefix || ""
        strip = @compileUnit.compiler.stripPrefix

        @name = prefix + @fileName.substring(strip.length).replace(/(\.(coffee|js))$/, "")

    prepare: (cb) ->
        async.series [
            (cb) => fs.readFile @fileName, "utf8", (err, @output) => cb(err)
            (cb) => @process(cb)
            (cb) => @wrap(cb)
        ], cb

    process: (cb) -> cb(null)

    wrap: (cb) -> cb(null)

class JavaScriptSourceFile extends SourceFile
    wrap: (cb) ->
        @output = "require.register(\"#{@name}\", function (module, exports, require) {\n#{@output}\n});\n// Module: #{@name}\n"
        cb(null)

class CoffeeScriptSourceFile extends JavaScriptSourceFile
    process: (cb) ->
        try
            @output = coffee.compile(@output, filename: @fileName, bare: true)
            cb(null)
        catch e
            @compileUnit.compiler.log "  \u001b[31m error in file: #{@fileName}\u001b[0m"
            @compileUnit.compiler.log e
            cb(e)

class JadeSourceFile extends SourceFile
    process: (cb) ->
        fn = jade.compile(@output, filename: @fileName)
        template = fn()
        start = "<script>".length
        start = template.indexOf("window.template._[") if @compileUnit.haveJade
        @compileUnit.haveJade = true
        @output = template.substring(start, template.length - "</script>".length)
        cb(null)

    wrap: (cb) ->
        @output = "// Jade: #{@name}\n#{@output}\n// End Jade: #{@name}\n"
        cb(null)

class CompileUnit
    process: (cb) -> cb(null)

    minify: (cb) ->
        statReply = (cb) ->
            (err, stats) ->
                err = null if err and err.code = 'ENOENT'
                cb(err, stats)

        async.parallel
            min: (cb) => fs.stat @minFile, statReply(cb)
            max: (cb) => fs.stat @maxFile, statReply(cb)
        , (err, data) =>
            return cb(err) if err
            return cb() if data.min && data.min.mtime >= data.max.mtime

            fs.readFile @maxFile, 'utf8', (err, src) =>
                return cb(err) if err

                task =
                    exec: (cb) =>
                        @doMinify(src, cb)

                minifier.push task, cb

    doMinify: (src, cb) ->
        closure.compile src, (err, out) =>
            return cb(err) if err
            @compiler.log "  \u001b[90m   create : \u001b[0m\u001b[36m%s\u001b[0m", @minFile.replace(@compiler.tmpPath, "tmp/js")
            fs.writeFile @minFile, out, cb

class LibraryCompileUnit extends CompileUnit
    constructor: (@compiler, @name) ->
        @maxFile = path.join @compiler.libPath, "#{@name}.js"
        @minFile = path.join @compiler.tmpPath, "#{@name}.min.js"

    doMinify: (src, cb) ->
        bundledPath = @maxFile.replace(/\.js$/, ".min.js")
        fs.exists bundledPath, (exists) =>
            if exists
                # Reuse bundled minified file.
                @compiler.log "  \u001b[90m   copy   : \u001b[0m\u001b[36m%s\u001b[0m", bundledPath.replace(@compiler.libPath, "lib/js")
                out = fs.createWriteStream(@minFile)
                out.on 'close', cb
                fs.createReadStream(bundledPath).pipe(out)
                return

            # Minify it ourselves.
            super(src, cb)


class SourceDirCompileUnit extends CompileUnit
    constructor: (@compiler) ->
        @srcPath = path.join @compiler.basePath, @compiler.options.path
        @maxFile = path.join @compiler.tmpPath, "#{@compiler.name}.js"
        @minFile = path.join @compiler.tmpPath, "#{@compiler.name}.min.js"

        @inputs = []
        @haveJade = false

    prepare: (cb) ->
        finder = walkdir(@srcPath)
        finder.on 'error', (err) -> # Ignore it!
        finder.on 'file', (file) => @queueSourceFile file
        finder.on 'end', (err) =>
            return cb(err) if err
            @inputs = fort.ascend @inputs, (input) -> input.fileName
            cb(null)

    queueSourceFile: (file) ->
        @inputs.push new CoffeeScriptSourceFile(@, file) if /\.coffee$/.test(file)
        @inputs.push new JavaScriptSourceFile(@, file) if /\.js$/.test(file)
        @inputs.push new JadeSourceFile(@, file) if /\.jade$/.test(file)

    makeHeader: () ->
        buf = ""
        buf += "require = " + browser.require + ";\n"
        buf += "require.modules = {};\n"
        buf += "require.register = " + browser.register + ";\n\n"
        return buf

    process: (cb) ->
        prepareSource = (file, cb) -> file.prepare(cb)
        async.forEachSeries @inputs, prepareSource, (err) =>
            return cb(err) if err
            
            buf = ""
            if !@compiler.options.skipHeader
                buf += @makeHeader()

            for item in @inputs
                buf += item.output

            if @compiler.options.initWith
                buf += "require(\"#{@compiler.options.initWith}\");\n"

            @compiler.log "  \u001b[90m   create : \u001b[0m\u001b[36m%s\u001b[0m", @maxFile.replace(@compiler.tmpPath, "tmp/js")
            fs.writeFile @maxFile, buf, cb

class Compiler
    constructor: (basePath, @name, @options = {}) ->
        @basePath = path.normalize basePath
        @tmpPath = path.normalize @basePath + "/tmp/js"
        @outPath = path.normalize @basePath + "/public/js"
        @libPath = path.normalize @basePath + "/lib/js"

        @stripPrefix = path.join(@basePath, @options.path) + '/'
        @buildQueue = []

    prepareOutput: (cb) ->
        async.parallel [
            (cb) => mkdirp @tmpPath, cb
            (cb) => mkdirp @outPath, cb
        ], cb

    queueLibraries: (cb) ->
        for lib in (@options.pack || [])
            @buildQueue.push new LibraryCompileUnit(@, lib)
        cb()

    queueSource: (cb) ->
        unit = new SourceDirCompileUnit(@)
        @buildQueue.push unit
        unit.prepare(cb)

    processQueue: (cb) ->
        buildItem = (item, cb) -> item.process(cb)
        async.forEach @buildQueue, buildItem, cb

    bundle: (file, out, separator, cb) ->
        sources = []

        bundleItem = (item, cb) ->
            fs.readFile item[file], 'utf8', (err, src) ->
                return cb(err) if err
                sources.push src
                cb()

        async.forEachSeries @buildQueue, bundleItem, (err) =>
            return cb(err) if err
            @log "  \u001b[90m   bundle : \u001b[0m\u001b[36m%s\u001b[0m", out.replace(@outPath, "public/js")
            fs.writeFile out, sources.join(separator), cb

    bundleMax: (cb) -> @bundle('maxFile', @outPath + "/#{@name}.bundle.js", ";\n", cb)
    bundleMin: (cb) -> @bundle('minFile', @outPath + "/#{@name}.bundle.min.js", "\n", cb)

    minifyQueue: (cb) ->
        minify = (item, cb) -> item.minify(cb)
        async.forEach @buildQueue, minify, cb

    log: () ->
        if @options.verbose
            console.log.apply @, arguments

    compile: (cb) ->
        async.series [
            (cb) => @prepareOutput(cb)
            (cb) => @queueLibraries(cb)
            (cb) => @queueSource(cb)
            (cb) => @processQueue(cb)
            (cb) => @bundleMax(cb)
        ], (err) =>
            return cb(err) if err
            cb(null) if !@options.wait

            async.series [
                (cb) => @minifyQueue(cb)
                (cb) => @bundleMin(cb)
            ], (err) =>
                cb(err) if @options.wait

module.exports =
    Compiler: Compiler
    middleware: (basepath, options) ->
        (req, res, next) ->
            return next() if req.app.settings.env != 'development'

            found = false
            for name, opts of options
                if req.url == "/js/#{name}.bundle.js"
                    found = true
                    c = new Compiler(basepath, name, opts)
                    c.compile(next)

            return next() if !found
