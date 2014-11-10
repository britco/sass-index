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
		ignore: [
		]

	# Add ignore paths that can't be overwrited
	opts = _.extend opts,
		ignore: _.uniq(opts.ignore.concat([
			'**/.DS_Store',
			'**/index.sass',
			'**/index.scss',
			'**/_index.sass',
			'**/_index.scss'
		]))

	opts.dir = dir = path.resolve(opts.basedir,opts.dir)

	# Resolve ignore paths to opts.basedir
	opts.ignore = opts.ignore.map (dir) ->
		return path.resolve(opts.basedir,dir)

	# Start searching for files
	walker = walkdir(dir)

	walker.on 'directory', (dir) ->
		return if shouldIgnorePath(dir)

		writeIndexFor(dir)

	# Check if file is marked as a path to ignore
	indexignore_cache = {}
	shouldIgnorePath = (file,stat=null) ->
		path = require('path')
		fs = require('fs')
		minimatch = require('minimatch')

		ignore_globs = opts.ignore

		unless stat?
			stat = fs.statSync(file)

		if stat.isDirectory()
			dir = file
		else
			dir = path.dirname(file)

		# Merge in entries from the .indexignore file if it exists
		if not _.has(indexignore_cache,dir)
			try
				indexignore_contents = fs.readFileSync(path.join(dir,'.indexignore'))
			catch
				indexignore_contents = null

			if indexignore_contents instanceof Buffer
				new_ignore_list = indexignore_contents.toString().split(/[\r|\n]/)
				new_ignore_list = _.filter(new_ignore_list, (subpath) => not _.isEmpty(subpath))
				ignore_globs = ignore_globs.concat(new_ignore_list.map((subfile) => path.resolve(dir,subfile)))

			indexignore_cache[dir] = ignore_globs
		else
			ignore_globs = indexignore_cache[dir]

		console.log ignore_globs

		# Now loop through ignore globs and check if the path matches any of them..
		# Checks for directories or files, see
		# https://github.com/EE/gitignore-to-glob/blob/master/lib/gitignore-to-glob.js#L53
		for ignore_glob in ignore_globs
			if minimatch(file, ignore_glob) or minimatch(file, ignore_glob + '/**')
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

			if not shouldIgnorePath(file,stat)
				if stat.isDirectory()
						files.push('./' + importName + '/index')
				else
					ext = path.extname(file)
					if (ext in opts.extensions)
						files.push('./' + importName.slice(0,ext.length * -1))

		if files.length is 0 then return false

		# Write the SASS file
		output = ""
		for file in files
			file = file.replace(/^\.\/\.\//,'./')
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
