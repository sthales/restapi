var gulp = require('gulp'),
    nodemon = require('gulp-nodemon');

    gulp.task('default',function(){
        nodemon({
            script:'servidor.js',
            ext:'js',
            env:{
                port:3501
            },
            ignore:['./node_modules/**']
        }).on('restart',function(){
            console.log('restarting');
        });
    });
