require 'nokogiri'

def list_svg_files(directory)
  Dir.glob(File.join(directory, '*.svg'))
end

def read_svg_file(file)
  File.read(file)
end

def extract_svg_elements(svg_content)
  doc = Nokogiri::XML(svg_content)
  doc.remove_namespaces!
  doc.xpath('//svg/g')
end

def create_combined_svg(elements, rows, columns, margin_top, margin_left)
  combined_svg = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.svg(xmlns: 'http://www.w3.org/2000/svg') {
      elements.each_with_index do |element, index|
        row = index / columns
        col = index % columns

        # Adjust the 'transform' attribute to position the element in the grid
        transform = "translate(#{col * (100 + margin_left)}, #{row * (100 + margin_top)})"
        element['transform'] = transform

        xml << element.to_xml
      end
    }
  end
  combined_svg.to_xml
end

def save_svg_to_file(svg, file)
  File.write(file, svg)
end

if ARGV.length != 6
  puts "Usage: ruby combine_svgs.rb <source_directory> <output_file> <rows> <columns> <margin_top> <margin_left>"
  exit(1)
end

source_directory = ARGV[0]
output_file = ARGV[1]
rows = ARGV[2].to_i
columns = ARGV[3].to_i
margin_top = ARGV[4].to_i
margin_left = ARGV[5].to_i

svg_files = list_svg_files(source_directory).sort_by { |file| File.basename(file, '.svg').to_i }[0...rows * columns]

combined_elements = svg_files.flat_map do |file|
  content = read_svg_file(file)
  extract_svg_elements(content)
end

combined_svg = create_combined_svg(combined_elements, rows, columns, margin_top, margin_left)
save_svg_to_file(combined_svg, output_file)

