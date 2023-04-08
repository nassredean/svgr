# frozen_string_literal: true

require "nokogiri"
require "optparse"

module Svgr
  class DocumentResize
    class << self
      def start(argv)
        options = {}
        parser = OptionParser.new do |opts|
          opts.banner = "Usage: svgr document:resize <width> <height> [--in INPUT_FILE] [--out OUTPUT_FILE]"

          opts.on("--in INPUT_FILE", "Specify the input file path") do |input_file|
            options[:input_file] = input_file
          end

          opts.on("--out OUTPUT_FILE", "Specify the output file path") do |output_file|
            options[:output_file] = output_file
          end

          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
          end
        end
        parser.parse!(argv)

        if argv.size < 2
          puts parser.help
          exit(1)
        end

        width = argv[0].to_f
        height = argv[1].to_f

        input_file = options[:input_file]
        output_file = options[:output_file]

        svg_content = if input_file
          File.read(input_file)
        else
          $stdin.read
        end

        resized_svg = resize(svg_content, width, height, input_file, output_file)

        # Write the output
        output = resized_svg.to_xml
        if output_file
          File.write(output_file, output)
        else
          puts output
        end
      end

      def resize(content, width, height, input_file, output_file)
        doc = Nokogiri.XML(content)
        doc.remove_namespaces!
        svg_element = doc.at_xpath("/svg")

        # Get the original SVG width and height
        svg_width = svg_element["width"].to_i
        svg_height = svg_element["height"].to_i

        # Calculate width and height in pixels using a DPI of 96
        width_px = (width * 96 / 25.4).round
        height_px = (height * 96 / 25.4).round

        # Calculate the difference between the new width and height and the original width and height
        width_diff = (width_px - svg_width) / 2
        height_diff = (height_px - svg_height) / 2

        # Update the width and height attributes of the SVG element
        svg_element["width"] = width_px
        svg_element["height"] = height_px

        # Create a new group element to wrap all the existing elements and apply the translation
        new_group = Nokogiri::XML::Node.new("g", doc)
        new_group["transform"] = "translate(#{width_diff}, #{height_diff})"
        svg_element.children.each do |child|
          new_group.add_child(child)
        end
        svg_element.add_child(new_group)

        doc
      end
    end
  end
end
