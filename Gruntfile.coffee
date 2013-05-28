module.exports = (grunt)->
  'use strict'

  GRUNT_CHANGED_PATH = '.grunt-changed-file'
  if grunt.file.exists GRUNT_CHANGED_PATH
    changed = grunt.file.read GRUNT_CHANGED_PATH
    grunt.file.delete GRUNT_CHANGED_PATH    
    changed_only = (file)-> file is changed
  else
    changed_only = (file)-> true

  grunt.initConfig
    connect:
      server:
        options:
          port: 3000
          base: '.'
          hostname: '0.0.0.0'
    watch:
      src:
        files: 'src/**/*.js'
        tasks: ['jshint', 'concat', 'docs', 'nodeunit']
      test:
        files: 'test/*.coffee'
        tasks: 'nodeunit'
      options:
        "no-color": true
    jshint:
      src:
        expand: true
        src   : 'src/**/*.js'
        filter: changed_only
      options:
        curly   : true
        eqeqeq  : true
        indent  : 2
        latedef : true
        noarg   : true
        noempty : true
        quotmark: 'double'
        undef   : true
        unused  : true
        strict  : true
        trailing: true
        newcap  : false
        browser : true
        node    : true
        predef  : ['sc']
    concat:
      src:
        src : ['src/sc.js', 'src/lib/*.js', 'src/tuning.js', 'src/scale.js']
        dest: 'build/subcollider.js'
    uglify:
      prototype:
        src : 'build/subcollider.js'
        dest: 'build/subcollider-min.js'
        options:
          sourceMap: 'build/subcollider-min.map'
    nodeunit:
      prototype:
        src: 'test/*.coffee'

  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-nodeunit'  
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.event.on 'watch', (action, changed)->
    grunt.file.write GRUNT_CHANGED_PATH, changed
  
  grunt.registerTask 'default', ['connect', 'watch']
  grunt.registerTask 'build'  , ['jshint', 'concat', 'nodeunit', 'uglify']
  grunt.registerTask 'docs'   , ->
    builder = new DocBulder
    opts = do builder.build
    html = require('jade').compile(grunt.file.read './docs/index.jade') data:opts
    grunt.file.write './docs/index.html', html

  # documents
  Array::trim = ->
    ret = @slice()
    ret.shift() while ret[0] is ''
    ret.pop()   while ret[ret.length-1] is ''
    ret

  class DocBulder
    build: ->
      docs = []
      for filepath in grunt.file.expand './src/lib/*.js'
        docs = docs.concat parse(filepath)

      index = [
        {category:"Array"   , data:sortIndex docs, "Array"   }
        {category:"Number"  , data:sortIndex docs, "Number"  }
        {category:"Function", data:sortIndex docs, "Function"}
        {category:"String"  , data:sortIndex docs, "String"  }
      ]
      body = sortBody docs
      index:index, body:body
    
    parse = (filepath)->
      getDocs filepath

    sortIndex = (docs, key)->
      docs = docs.filter (doc)->
        doc.category.indexOf(key) != -1
      docs = docs.map (doc)->
        name:doc.name, tag:doc.tag
      docs = docs.sort compareKeys

    sortBody = (docs)->
      [ ret, tag ] = [ [], {} ]
      Object.keys(docs).forEach (key)->
        if not tag[docs[key].tag]
          tag[docs[key].tag] = true
          ret.push docs[key]
      ret

    compareKeys = (a, b)->
      [a, b] = [a.name, b.name]
      if Array.isArray(a) then a = a[0]
      if Array.isArray(b) then b = b[0]
      if not /^\*\w+$/.test(a) then a = "^#{a}"
      if not /^\*\w+$/.test(b) then b = "^#{b}"
      switch
        when a < b then -1
        when a > b then +1
        else 0
    getDocs = (filepath)->
      ret = [{}]
      src = grunt.file.read filepath
      for line in src.split '\n'
        line = line.trim()
        if line is '/**'
          if ret[ret.length-1].name
            ret.push {}
          key = "description"
        else if line is '*/' and key
          key = null
        else
          obj = ret[ret.length-1]
          if key and line.charAt(0) is '*'
            line = line.substr 2
            if (m = /^@(\w+)\s*(.*)$/.exec line)
              [_, key, line] = m
            (obj[key] ? obj[key]=[]).push line
          else
            if (m = /sc\.register\((.+?),\s*{$/.exec line)
              x = JSON.parse m[1]
              [name, aliases] = if Array.isArray x
                [x[0], x.slice(1).join ", "]
              else
                [x, ""]
              if ret[ret.length-1].name
                ret.push obj = {}
              obj.name    = name
              obj.aliases = aliases
            else if (m = /(Number|Boolean|Array|String|Function)\s*:\s*/.exec line)
              obj.category = [] if not obj.category
              obj.category.push m[1]
      ret.map (obj)->
        for key of obj
          if key != "category" and Array.isArray obj[key]
            obj[key] = obj[key].trim().join '\n'
          if typeof obj[key] is 'string'
            obj[key] = marked obj[key]
        obj.src ?= filepath.substr(2)
        obj.tag ?= obj.name
        obj
    marked = (text)->
      text = text.replace /\*(.*?)\*/g, '<b>$1</b>'
      text = text.replace /\_(.*?)\_/g, '<i>$1</i>'
      text = text.replace /\`(.*?)\`/g, '<code>$1</code>'