module.exports = (grunt) ->
    @loadNpmTasks('grunt-contrib-clean')
    @loadNpmTasks('grunt-contrib-coffee')
    @loadNpmTasks('grunt-contrib-watch')

    @initConfig
        coffee:
            all:
                expand: true,
                cwd: 'src',
                src: ['*.coffee'],
                dest: 'lib',
                ext: '.js'

        clean:
            all: ['lib']

        watch:
            all:
                files: ['src/**.coffee']
                tasks: ["clean", "coffee"]
                options:
                    nospawn: true

    @registerTask "npmPack", "Create NPM package.", ->
        done = @async()

        grunt.util.spawn
            cmd: "npm"
            args: ["pack"]
        , (error, result, code) ->
            grunt.log.writeln(result.stderr) if result.stderr
            grunt.log.writeln(result.stdout) if result.stdout
            done(!error)

    @registerTask "default", ["clean", "coffee"]
    @registerTask "package", ["clean", "coffee", "npmPack"]
