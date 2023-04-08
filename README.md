# SVGR

SVGR is a command-line utility for manipulating SVG files. It provides a set of commands to perform various tasks on SVG files, such as arranging elements in a grid and resizing the document. The tool is designed to be easily extensible, allowing for the addition of new SVG-related utilities and commands in the future.

## Installation

### Building manually
Clone this repository and navigate to the project folder:

```
git clone https://github.com/nassredean/svgr.git
bundle install
```

### Installing from rubygems

```
gem install svgr
```

## Usage

SVGR provides the following commands:

### `arrange:grid`

This command combines multiple SVG files into a single SVG, arranging the elements in a grid.

```
svgr arrange:grid <source_directory> <rows> <columns> [options]
```

Options:

- `--scaling-factor`: Scaling factor applied to each element (default: 1).
- `--margin`: Margin between elements in the grid, as a hash with optional `top` and `left` keys (default: `{}`).
- `--sort`: Sort order for the SVG files (`alphabetical`, `reverse`, or `random`).

Example:

```
bin/svgr arrange:grid spec/fixtures/coiledwall 3 1 --scaling-factor 3 --sort random
```

### `document:resize`

This command resizes the document of an SVG file to the specified width and height in millimeters, without scaling the elements. It can read from a file or accept input from a pipe.

Options:

- `--in`: Path to the input SVG file.
- `--out`: Path to the output SVG file.

Examples:

```
bin/svgr document:resize 210 285 --in input.svg --out output.svg
```

Using pipes:

```
bin/svgr arrange:grid spec/fixtures/coiledwall 3 1 --scaling-factor 3 --sort random | bin/svgr document:resize 210 285
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](LICENSE)
