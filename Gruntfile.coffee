# gruntfile

module.exports = (grunt) ->
  grunt.initConfig

    coffee:
      build:
        expand: yes
        flatten: no
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'build'
        ext: '.js'

      examples:
        expand: yes
        flatten: no
        cwd: 'examples'
        src: ['**/*.coffee']
        dest: 'www'
        ext: '.js'

    browserify:
      build:
        src: ['build/client.js']
        dest: 'www/script.js'

    mochaTest:
      options:
        require: ["coffee-script/register"]
      test:
        src: ["test/**/*.coffee"]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', ['mochaTest', 'coffee', 'browserify']
