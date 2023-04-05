Gem::Specification.new do |spec|
  spec.name = "svgr"
  spec.version = "0.1.0"
  spec.authors = ["Nassredean Nasseri"]
  spec.summary = "A tool for working with SVG files"
  spec.description =
    "A Ruby gem that provides a command-line interface for various SVG utilities"
  spec.homepage = "https://github.com/nassredean/svgr"
  spec.license = "MIT"

  spec.files = Dir["lib/**/*.rb"] + Dir["bin/*"]
  spec.bindir = "bin"
  spec.executables = ["svgr"]
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.12"
end
