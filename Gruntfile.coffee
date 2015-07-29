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
        src: ['build/init.js']
        dest: 'www/script.js'

    mochaTest:
      options:
        require: ["coffee-script/register"]
      test:
        src: ["test/**/*.coffee"]

    clean:
      files: ["build", "www/script.js"]

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', ['clean', 'mochaTest', 'coffee', 'browserify']
