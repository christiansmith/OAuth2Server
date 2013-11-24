module.exports = function (grunt) {

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-cov');
  grunt.loadNpmTasks('grunt-release');

  grunt.initConfig({
    watch: {
      test: {
        files: [
          'config/**/*.js',
          'models/**/*.js',
          'routes/**/*.js',
          'test/**/*.coffee'
        ],
        tasks: ['mochacov']
      }
    },
    mochacov: {
      options: {
        reporter: 'dot',
        compilers: ['coffee:coffee-script']
      },
      all: [
        'test/models/**/*.coffee',
        'test/routes/**/*.coffee'
      ]
    }
  });

  grunt.registerTask('test', ['mochacov', 'watch:test']);
  
};
