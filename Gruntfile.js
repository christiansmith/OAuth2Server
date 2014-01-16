module.exports = function (grunt) {

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-cov');
  grunt.loadNpmTasks('grunt-release');
  grunt.loadNpmTasks('grunt-retire');

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
        reporter: 'spec',
        compilers: ['coffee:coffee-script']
      },
      all: [
        'test/models/**/*.coffee',
        'test/routes/**/*.coffee'
      ]
    },
    retire: {
      node: ['.']
    }
  });

  grunt.registerTask('test', ['mochacov', 'watch:test']);

};
