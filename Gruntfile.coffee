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

    browserify:
      build:
        src: ['build/app.js']
        dest: 'www/script.js'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-browserify'

  grunt.registerTask 'default', ['coffee', 'browserify']
