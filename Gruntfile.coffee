module.exports = (grunt) ->
    @loadNpmTasks('grunt-contrib-clean')
    @loadNpmTasks('grunt-contrib-coffee')
    @loadNpmTasks('grunt-contrib-watch')
    @loadNpmTasks('grunt-contrib-copy')
    @loadNpmTasks('grunt-mocha-cli')
    @loadNpmTasks('grunt-release')

    @initConfig
        coffee:
            options:
                bare: true
            all:
                expand: true,
                cwd: 'src',
                src: ['*.coffee'],
                dest: 'lib',
                ext: '.js'

        clean:
            all: ['lib', 'tmp']

        copy:
            test:
                files: [
                    src: ['**' ]
                    dest: 'tmp/'
                    cwd: 'test/projects/'
                    expand: true
                ]

        watch:
            all:
                files: ['src/**.coffee', 'test/**']
                tasks: ['test']

        mochacli:
            options:
                files: 'test/*_test.coffee'
                compilers: ['coffee:coffee-script']
            spec:
                options:
                    reporter: 'spec'
                    slow: 10000
                    timeout: 20000

    @registerTask 'default', ['test']
    @registerTask 'build', ['clean', 'coffee']
    @registerTask 'package', ['build', 'release']
    @registerTask 'test', ['build', 'copy:test', 'mochacli']
