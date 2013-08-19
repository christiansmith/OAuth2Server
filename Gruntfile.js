module.exports = function (grunt) {

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-cov');

  grunt.initConfig({
    watch: {
      test: {
        files: [
          'models/**/*.js',
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
        'test/models/**/*.js',
        'test/authentication/**/*.js',
        'test/authorization/**/*.js'
      ]
    }
  });

  grunt.registerTask('test', ['mochacov', 'watch:test']);
  
};