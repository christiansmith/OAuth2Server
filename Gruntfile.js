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
          'test/**/*.js',
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
        'test/models/**/*.js',
        'test/models/**/*.coffee',
        'test/routes/**/*.js',
        'test/routes/**/*.coffee'
      ]
    }
  });

  grunt.registerTask('test', ['mochacov', 'watch:test']);
  
};
