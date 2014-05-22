sass-index
==========
Given a directory, generates an index.sass file for this directory, and any
nested directories.


## Example

For directory structure:
````
SASS_FILES
	foo.sass
	bar.sass
````

When you run:
````
require('sass-index')(
	dir: 'SASS_FILES/'
)
````

Adds a new file at SASS_FILES/index.sass, containing:
````
@import "./foo"
@import "./bar"
````

## Options:

### basedir
	Base directory where the SASS files are located.

__Default__: `./`

### dir
	Directory to generate index of.

__Default__: `./`

### extensions

List of extensions you want to analyze.

__Default__: `['.sass','.scss']`

### ignore_dirs
Directories to ignore in index generation.

__Default__: `[]`

### ignore_files
Files to ignore in index generation.

__Default__:
````
[
	'.DS_Store',
	'index.sass',
	'index.scss',
	'_index.sass',
	'_index.scss'
]
````

## License
Available under the [MIT License](LICENSE.md).