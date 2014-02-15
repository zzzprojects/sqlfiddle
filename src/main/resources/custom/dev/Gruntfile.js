module.exports = function(grunt) {

    grunt.initConfig({
        watch: {
            copy: {
                files: ['../ui/**/*.js','../**/*.groovy', '../ui/**/*.html', '../conf/*.json', '../ui/**/*.less', '../ui/**/*.css'],
                tasks: [ 'sync' ]
            }
        },
        sync: {
            custom: {
                files: [{
                    cwd     : '..',
                    src     : ['**/*'], 
                    dest    : '../../../../../target/sqlfiddle',
                    flatten : false,
                    expand  : true
                }]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-sync');
    
    grunt.registerTask('default', ['watch']);

};
