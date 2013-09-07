path = require 'path'

# Build configurations.
module.exports = (grunt) ->
  grunt.initConfig
    # Deletes dist and temp directories.
    # The temp directory is used during the build process.
    # The dist directory contains the artifacts of the build.
    # These directories should be deleted before subsequent builds.
    # These directories are not committed to source control.
    clean:
      working:
        src: [
          './dist/'
          './dist_test/'
          './.temp/'
        ]

    #compile livescript (.ls) files to javascript (.js)
    lsc:
      scripts:
        files: [
          cwd: './src/'
          src: 'scripts/**/*.ls'
          dest: './.temp/'
          expand: true
          ext: '.js'
        ,
          cwd: './test/'
          src: ['scripts/**/*.ls','pubs/**/*.ls']
          dest: './dist_test/'
          expand: true
          ext: '.js'
        ]
        options:
          # Don't include a surrounding Immediately-Invoked Function Expression (IIFE) in the compiled output.
          # For more information on IIFEs, please visit http://benalman.com/news/2010/11/immediately-invoked-function-expression/
          bare: true

    # Compile CoffeeScript (.coffee) files to JavaScript (.js).
    coffee:
      scripts:
        files: [
          cwd: './src/'
          src: 'scripts/**/*.coffee'
          dest: './.temp/'
          expand: true
          ext: '.js'
        ,
          cwd: './test/'
          src: ['scripts/**/*.coffee','pubs/**/*.coffee']
          dest: './dist_test/'
          expand: true
          ext: '.js'
        ]
        options:
          # Don't include a surrounding Immediately-Invoked Function Expression (IIFE) in the compiled output.
          # For more information on IIFEs, please visit http://benalman.com/news/2010/11/immediately-invoked-function-expression/
          bare: true

      # Used for those that desire plain old JavaScript.
      jslove:
        files: [
          cwd: './'
          src: [
            '**/*.coffee'
            '!**/node_modules/**'
          ]
          dest: './'
          expand: true
          ext: '.js'
        ]
        options: '<%= coffee.scripts.options %>'

    # Compile template files (.html) -> (.html).
    #
    # You can take advantage of features provided by grunt such as underscore templating in the
    # source html. These templates are interpolated during the copy from ./src to ./temp
    #
    # The example below demonstrates the use of the environment configuration setting.
    # In 'prod' the concatenated and minified scripts are used along with a QueryString parameter of the hash of the file contents to address browser caching.
    # In environments other than 'prod' the individual files are used and loaded with RequireJS.
    #
    # <% if (config.environment === 'prod') { %>
    #   <script src="/scripts/scripts.min.js?v=<%= config.hash('./.temp/scripts/scripts.min.js') %>"></script>
    # <% } else { %>
    #   <script data-main="/scripts/main.js" src="/scripts/libs/require.js"></script>
    # <% } %>
    template:
      views:
        files:
          './.temp/views/': './src/views/**/*.html'
          './.temp/views/pubs': './src/scripts/pubs/**/*.html'
      dev:
        files:
          './.temp/index.html': './src/index.html'
          './.temp/views/pubs': './src/scripts/pubs/**/index.html'
        environment: 'dev'
      prod:
        files: '<%= template.dev.files %>'
        environment: 'prod'

    # Copies directories and files from one location to another.

    copy:
      # restriction to mask only
      mask:
        files: [
          cwd: './.temp/scripts/pubs/mask'
          src: ['main.js', 'routes.js', 'services/semver.js']
          dest: './.temp/scripts/'
          expand: true
        ,
          cwd: './.temp/views/pubs/mask'
          src: ['index.html', 'views/*.html']
          dest: './.temp/'
          expand: true
        ]
      
      # Copies img directory to temp.
      img: 
        files: [
          cwd: './src/'
          src: '**/*.png'
          dest: './.temp/'
          expand: true       
        ]

      # Copy fonts
      fonts:
        files: [
          cwd: './src/'
          src: ['**/*.ttf','**/*.svg','**/*.woff']
          dest: './.temp/'
          expand: true
        ]

      # Copies js files to the temp directory
      js:
        files: [
          cwd: './src/'
          src: 'scripts/**/*.js'
          dest: './.temp/'
          expand: true
        ,
          cwd: './src/'
          src: 'scripts/**/*.js'
          dest: './dist_test/'
          expand: true
        ]

      # Copies the contents of the temp directory, to the dist directory.
      # In 'dev' individual files are used.
      dev:
        files: [
          cwd: './.temp/'
          src: '**'
          dest: './dist/'
          expand: true
        ]

      # Copies select files from the temp directory to the dist directory.
      # In 'prod' minified files are used along with img and libs.
      # The dist artifacts contain only the files necessary to run the application.
      prod:
        files: [
          cwd: './.temp/'
          src: [
            'img/**/*.png'
            'scripts/pubs/**/*.png'
            'scripts/libs/html5shiv-printshiv.js'
            'scripts/libs/json2.js'
            'scripts/scripts.min.js'
            'styles/styles.min.css'
          ]
          dest: './dist/'
          expand: true
        ,
          './dist/index.html': './.temp/index.min.html'
        ]

      # Task is run when the watched index.template file is modified.
      index:
        files: [
          cwd: './.temp/'
          src: 'index.html'
          dest: './dist/'
          expand: true
        ]
      # Task is run when a watched script is modified.
      scripts:
        files: [
          cwd: './.temp/'
          src: 'scripts/**'
          dest: './dist/'
          expand: true
        ]
      # Task is run when a watched style is modified.
      styles:
        files: [
          cwd: './.temp/'
          src: 'styles/**'
          dest: './dist/'
          expand: true
        ]
      # Task is run when a watched view is modified.
      views:
        files: [
          cwd: './.temp/'
          src: '**/*.html'
          dest: './dist/'
          expand: true
        ]

    # Start an Express server + live reload.
    express:
      livereload:
        options:
          port: 3005
          bases: path.resolve './dist'
          debug: true
          monitor: {}
          server: path.resolve './server'

    # Compresses png files
    # imagemin:
    #   img:
    #     files: [
    #       cwd: './src/'
    #       src: '**/*.png'
    #       dest: './.temp/'
    #       expand: true
    #     ]
    #     options:
    #       optimizationLevel: 7

    # Compile LESS (.less) files to CSS (.css).
    less:
      styles:
        files:
          './.temp/styles/styles.css': './src/styles/styles.less'

    # Minifiy index.html.
    # Extra white space and comments will be removed.
    # Content within <pre /> tags will be left unchanged.
    # IE conditional comments will be left unchanged.
    # As of this writing, the output is reduced by over 14%.
    minifyHtml:
      prod:
        files:
          './.temp/index.min.html': './.temp/index.html'

    #
    # This file is then included in the output automatically.  AngularJS will use it instead of going to the file system for the views, saving requests.  Notice that the view content is actually minified.  :)
    ngTemplateCache:
      views:
        files:
          './.temp/scripts/views.js': ['./.temp/views/**/*.html', '!./.temp/views/pubs/**/*.html']
        options:
          trim: './.temp'


    # RequireJS optimizer configuration for both scripts and styles.
    # This configuration is only used in the 'prod' build.
    # The optimizer will scan the main file, walk the dependency tree, and write the output in dependent sequence to a single file.
    # Since RequireJS is not being used outside of the main file or for dependency resolution (this is handled by AngularJS), RequireJS is not needed for final output and is excluded.
    # RequireJS is still used for the 'dev' build.
    # The main file is used only to establish the proper loading sequence.
    requirejs:
      scripts:
        options:
          baseUrl: './.temp/scripts/'
          findNestedDependencies: true
          logLevel: 0
          mainConfigFile: './.temp/scripts/main.js'
          name: 'main'
          # Exclude main from the final output to avoid the dependency on RequireJS at runtime.
          onBuildWrite: (moduleName, path, contents) ->
            modulesToExclude = ['main']
            shouldExcludeModule = modulesToExclude.indexOf(moduleName) >= 0

            return '' if shouldExcludeModule

            contents
          optimize: 'uglify'
          out: './.temp/scripts/scripts.min.js'
          preserveLicenseComments: false
          skipModuleInsertion: true
          uglify:
            # Let uglifier replace variables to further reduce file size.
            no_mangle: false
      styles:
        options:
          baseUrl: './.temp/styles/'
          cssIn: './.temp/styles/styles.css'
          logLevel: 0
          optimizeCss: 'standard'
          out: './.temp/styles/styles.min.css'

    # Sets up file watchers and runs tasks when watched files are changed.
    watch:
      mask:
        files: [
          '.appmask'
          '/src/scripts/pubs/**/*.html'
        ]
        tasks: [
          'appstyles'
          'less'
          'template:views'
          'copy:views'
          'template:dev'
          'copy:index'
          'restrict'
          'copy:dev'
        ]
      index:
        files: './src/index.html'
        tasks: [
          'template:views'
          'copy:views'
          'template:dev'
          'copy:index'
          'restrict'
          'copy:dev'
        ]
      scripts:
        files: [
          './src/scripts/**/*.coffee'
          './src/scripts/**/*.ls'
          './src/scripts/**/*.js'
          './test/scripts/**/*.coffee'
          './test/scripts/**/*.ls'
          './test/scripts/**/*.js'
        ]
        tasks: [
          'coffee:scripts'
          'lsc:scripts'
          'copy:js'
          'copy:scripts'
          'restrict'
          'copy:dev'
        ]
      styles:
        files: [
          './src/styles/**/*.less'
          './src/scripts/pubs/styles.less'
          './src/scripts/pubs/*/styles.less'
        ]
        tasks: [
          'appstyles'
          'less'
          'copy:styles'
          'livereload'
        ]
      views:
        files: ['./src/**/*.html']
        tasks: [
          'template:views'
          'copy:views'
          'template:dev'
          'copy:index'
          'restrict'
          'copy:dev'
        ]

    # Restart server when server sources have changed, notify all browsers on change.
    regarde:
      dist:
        files: './dist/**'
        tasks: 'livereload'
      server:
        files: [
          'server.coffee'
          'routes.coffee'
        ]
        tasks: 'express-restart:livereload'

    # Runs unit tests using karma
    karma:
      unit:
        options:
          autoWatch: true
          browsers: ['Chrome']
          colors: true
          configFile: './karma.conf.js'
          keepalive: true
          port: 8081
          reporters: ['progress']
          runnerPort: 9100
          singleRun: false

  # Register grunt tasks supplied by grunt-contrib-*.
  # Referenced in package.json.
  # https://github.com/gruntjs/grunt-contrib
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  #grunt.loadNpmTasks 'grunt-contrib-imagemin'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-livereload'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  # livescript compiler
  grunt.loadNpmTasks('grunt-lsc')

  # Express server + LiveReload
  grunt.loadNpmTasks 'grunt-express'

  # Register grunt tasks supplied by grunt-hustler.
  # Referenced in package.json.
  # https://github.com/CaryLandholt/grunt-hustler
  grunt.loadNpmTasks 'grunt-hustler'

  # Recommended watcher for LiveReload + Express.
  grunt.loadNpmTasks 'grunt-regarde'

  # Register grunt tasks supplied by grunt-karma.
  # Referenced in package.json.
  # https://github.com/Dignifiedquire/grunt-karma
  grunt.loadNpmTasks 'grunt-karma'


  # Compiles the app with non-optimized build settings, places the build artifacts in the dist directory, and runs unit tests.
  # Enter the following command at the command line to execute this build task:
  # grunt test
  grunt.registerTask 'test', [
    'default'
    'karma'
  ]

  # Starts a web server
  # Enter the following command at the command line to execute this task:
  # grunt server
  grunt.registerTask 'server', [
    'livereload-start'
    'express'
    'regarde'
  ]

  # Compiles all CoffeeScript files in the project to JavaScript then deletes all CoffeeScript files.
  # Used for those that desire plain old JavaScript.
  # Enter the following command at the command line to execute this build task:
  # grunt jslove
  grunt.registerTask 'jslove', [
    'coffee:jslove'
    'clean:jslove'
  ]

  # if appmask is set limit the css styles needed
  grunt.registerTask 'appstyles', "Include only styles for app mask", ->
    mask = ''
    if grunt.file.exists '.appmask'
      mask = grunt.file.read '.appmask'
    if mask.length == 0
      # include all apps styles
      styleFiles = grunt.file.expand({cwd:'./src/scripts/pubs/'}, '*/*.less')
    else
      styleFiles = grunt.file.expand({cwd:'./src/scripts/pubs/'}, mask+'/*.less')
    styleFileContent = ''
    styleFiles.forEach (f) ->
      imp = '@' +'import "'
      imp += f
      imp += '";'
      grunt.log.writeln imp
      styleFileContent += grunt.util.normalizelf(imp + '\n')
    grunt.file.write('./src/scripts/pubs/styles.less', styleFileContent)

  # Read and apply the application mask
  grunt.registerTask 'restrict', "Read and apply the application mask", ->
    mask = ''
    if grunt.file.exists '.appmask'
      mask = grunt.file.read '.appmask'

    # if mask is non trivial
    if mask.length > 0
      # discover whether a custom copy:<mask> exists
      customConfig = grunt.config 'copy.'+mask
      if customConfig?
        grunt.log.writeln "Running copy:"+mask
        grunt.task.run [ "copy:"+mask ]
      else
        grunt.log.writeln "Running generic copy:mask"

        files = grunt.config 'copy.mask.files'
        files.forEach (f) ->
          cwd = f.cwd.replace /mask/, mask
          f.src.forEach (p) ->
            maps = grunt.file.expandMapping p, f.dest, {cwd:cwd} 
            maps.forEach (m) ->
              grunt.log.writeln("copy: " + m.src + " -> " + m.dest)
              grunt.file.copy('./'+m.src, './'+m.dest)

        files = grunt.config 'copy.mask.files'
        files.forEach (f) ->
          cwd = f.cwd.replace /mask/, mask
          f.src.forEach (p) ->
            maps = grunt.file.expandMapping p, f.dest, {cwd:cwd} 
            maps.forEach (m) ->
              grunt.log.writeln("copy: " + m.src + " -> " + m.dest)
              grunt.file.copy('./'+m.src, './'+m.dest)


  grunt.registerTask 'mask', "Set mask to restrict apps in page. e.g. grunt mask:frogs", (mask) ->
    grunt.file.write '.appmask', mask
    grunt.log.writeln 'grunt dev and grunt prod will display ', mask, ' mask apps.'
 
  grunt.registerTask 'unmask', "Unset mask to display all apps", () ->
    grunt.file.write '.appmask', ""
    grunt.log.writeln 'grunt dev and grunt prod will display all apps'


  #
  # Create a new app
  #
  grunt.registerTask 'create', "Create boilerplate for a new app", (mask) ->
    grunt.file.write '.appmask', mask
    grunt.log.writeln 'create', mask

    data =
      mask: mask
      apptitle: (mask.substr(0,1).toUpperCase() + mask.substr(1))
      delimiters: 'curlies'

    #grunt.log.writeln "data.mask = ", data.mask
    #grunt.log.writeln "data.apptitle = ", data.apptitle

    # create the pubs application folder
    appDir = './src/scripts/pubs/'+mask
    if grunt.file.exists appDir
      grunt.warn (appDir + ' already exists.'), 6
    else
      grunt.template.addDelimiters('curlies', '{%', '%}')
      grunt.file.mkdir('./src/scripts/pubs/'+mask)

      # copy appTemplate files to it, rewriting the app name in the process
      cwd = './boilerplate'
      templateFiles = grunt.file.expand {cwd: cwd}, '**/*'
      templateFiles.forEach (tf) ->
        src = cwd + '/' + tf
        if grunt.file.isFile src
          dest = appDir + '/' + tf.replace('mask', mask)
          grunt.log.writeln "copy boilerplate file ", src, " to ", dest

          # couldn't get the standard lodash templates to behave,
          # so this is a kludgy search and replace
          if(tf == 'index.html')
            content = grunt.file.read(src).replace(/\<%= mask %\>/g, data.apptitle)
          else
            content = grunt.file.read(src).replace(/\<%= mask %\>/g, data.mask)
            #content = grunt.template.process(grunt.file.read(src), {data: data})
          grunt.file.write dest, content

      grunt.log.writeln ""
      grunt.log.oklns "Now you need to create a main view and nav html in src/views, and edit the generic main.ls and routes."



  # Compiles the app with non-optimized build settings and places the build artifacts in the dist directory.
  # Enter the following command at the command line to execute this build task:
  # grunt
  grunt.registerTask 'default', "Default dev build", [
    'clean:working'
    'coffee:scripts'
    'lsc:scripts'
    'copy:js'
    'appstyles'
    'less'
    'template:views'
    'copy:img'
    'copy:fonts'
    'template:dev'
    'restrict'
    'copy:dev'
  ]

  # Compiles the app with non-optimized build settings, places the build artifacts in the dist directory, and watches for file changes.
  # Enter the following command at the command line to execute this build task:
  # grunt dev
  grunt.registerTask 'dev', "Dev build and watch for file changes", [
    'default'
    'watch'
  ]

  # Compiles the app with optimized build settings and places the build artifacts in the dist directory.
  # Enter the following command at the command line to execute this build task:
  # grunt prod
  grunt.registerTask 'prod', "Production build for currently masked apps", [
    'clean:working'
    'coffee:scripts'
    'lsc:scripts'
    'copy:js'
    'appstyles'
    'less'
    'template:views'
    'copy:img'
    'copy:fonts'
    'template:prod'
    'restrict'
    #'imagemin'
    'ngTemplateCache'
    'requirejs'
    'minifyHtml'
    'copy:prod'
  ]

