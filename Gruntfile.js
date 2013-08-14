module.exports = function (grunt) {

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-cov');

  grunt.initConfig({
    watch: {
      test: {
        files: [
          'test/**/*.js'
        ],
        tasks: ['mochacov']
      }
    },
    mochacov: {
      options: {
        reporter: 'spec'
      },
      all: [
        'test/authentication/**/*.js',
        'test/authorization/**/*.js'
      ]
    }
  });

  grunt.registerTask('test', ['mochacov', 'watch:test']);
  
};