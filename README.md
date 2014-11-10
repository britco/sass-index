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

### ignore
Paths to ignore in index generation. Accepts glob syntax, like path/**.

__Default__: `[]`

## License
Available under the [MIT License](LICENSE.md).
