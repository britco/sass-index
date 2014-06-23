path = require('path')
fs = require('fs')
util = require('util')
events = require('events')
_ = require('underscore')
walkdir = require('walkdir')

index = (opts) ->
	# Collect arguments.. can be in various formats
	if not _.isObject(opts) then opts = { dir: dir }

	_.defaults opts,
		basedir: './'
		dir: './'
		extensions: ['.sass','.scss']
		ignore_dirs:['./bootstrap','./bundles']
		ignore_files: [
			'.DS_Store',
			'index.sass',
			'index.scss',
			'_index.sass',
			'_index.scss'
		]

	opts.dir = dir = path.resolve(opts.basedir,opts.dir)

	console.log 'dir',opts.basedir,opts.dir

	opts.ignore_dirs = opts.ignore_dirs.map (dir) ->
		return path.resolve(opts.basedir,dir)

	# Start searching for files
	walker = walkdir(dir)

	walker.on 'directory', (dir) ->
		return if shouldIgnoreDir(dir)

		writeIndexFor(dir)

	# Check if you should ignore a directory
	shouldIgnoreDir = (dir) ->
		for ignore_dir in opts.ignore_dirs
			if dir.indexOf(ignore_dir) is 0
				return true

		return false

	# Write the SASS index file for a directory
	writeIndexFor = (dir) =>
		files = []

		if fs.existsSync(path.join(dir,'.indexkeep'))
			return false

		walkdir.sync dir, no_recurse: true, (file,stat) ->
			relative = path.relative(dir,file)
			importName = './' + relative

			if stat.isDirectory()
				if not shouldIgnoreDir(file)
					files.push('./' + importName + '/index')
			else
				ext = path.extname(file)
				if (
					ext in opts.extensions and
					path.basename(file) not in opts.ignore_files
				)
					files.push('./' + importName.slice(0,ext.length * -1))

		if files.length is 0 then return false

		# Write the SASS file
		output = ""
		for file in files
			output += """@import "#{file}"\n"""

		output = output.trim()

		if fs.existsSync(path.resolve(dir,"./_index.sass"))
			outputFile = path.resolve(dir,"./_index.sass")
		else
			outputFile = path.resolve(dir,"./index.sass")

		fs.writeFileSync(outputFile,output)

		this.emit("data", outputFile, output)

	walker.on 'end', =>
		# Write an index for the root dir.
		writeIndexFor(opts.dir)

		# And then return
		this.emit("end")

	return events.EventEmitter.call(this)

# Return instance on include
util.inherits(index,events.EventEmitter)
module.exports = -> new index(arguments...)