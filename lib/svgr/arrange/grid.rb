# frozen_string_literal: true

require "nokogiri"
require "optparse"

module Svgr
  module Arrange
    class Grid
      class << self
        def start(argv)
          options = {
            scaling_factor: 1,
            margin_top: 0,
            margin_left: 0,
            rows: 1,
            columns: 1,
            directory: Dir.pwd
          }

          opt_parser =
            OptionParser.new do |opts|
              opts.banner =
                "Usage: svgr arrange:grid [options] <file_paths> <rows> <columns>"

              opts.on(
                "-s",
                "--scaling-factor FACTOR",
                Float,
                "Scaling factor for the SVG elements",
              ) { |s| options[:scaling_factor] = s }

              opts.on(
                "-t",
                "--margin-top MARGIN",
                Integer,
                "Top margin between the SVG elements",
              ) { |t| options[:margin_top] = t }

              opts.on(
                "-l",
                "--margin-left MARGIN",
                Integer,
                "Left margin between the SVG elements",
              ) { |l| options[:margin_left] = l }

              opts.on(
                "-d",
                "--directory DIRECTORY",
                String,
                "Directory where .svg files are located",
              ) { |d| options[:directory] = d }

              opts.on(
                "-r",
                "--rows ROWS",
                Integer,
                "Number of rows to use",
              ) { |r| options[:rows] = r }

              opts.on(
                "-c",
                "--columns COLUMNS",
                Integer,
                "Number of columns to use",
              ){ |c| options[:columns] = c }

              opts.on("-h", "--help", "Prints this help") do
                puts opts
                exit
              end
            end
          opt_parser.parse!(argv)

          rows = options[:rows].to_i
          columns = options[:columns].to_i

          svg_files = Dir[File.join(options[:directory], "*.svg")][0..rows*columns]

          combined_elements =
            svg_files.flat_map do |file|
              content = read_svg_file(file)
              extract_svg_elements(content)
            end

          combined_svg = create_combined_svg(
            combined_elements,
            options[:rows],
            options[:columns],
            options[:scaling_factor],
            margin: { top: options[:margin_top], left: options[:margin_left] },
          )

          write_svg(combined_svg)
        end

        def read_svg_file(file)
          File.read(file)
        end

        def extract_svg_elements(svg_content)
          doc = Nokogiri.XML(svg_content)
          doc.remove_namespaces!
          top_level_groups = doc.xpath("//svg/g")

          if top_level_groups.empty?
            # Wrap all child elements of the SVG document in a group
            svg_element = doc.at_xpath("//svg")
            new_group = Nokogiri::XML::Node.new("g", doc)

            svg_element.children.each { |child| new_group.add_child(child) }

            svg_element.add_child(new_group)
            top_level_groups = [new_group]
          end

          top_level_groups
        end

        def create_combined_svg(
          elements,
          rows,
          columns,
          scaling_factor,
          margin: {}
        )
          margin_top = margin.fetch(:top, 0)
          margin_left = margin.fetch(:left, 0)

          width =
            columns * 100 * scaling_factor +
            (columns - 1) * margin_left * scaling_factor
          height =
            rows * 100 * scaling_factor + (rows - 1) * margin_top * scaling_factor

          combined_svg =
            Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
              xml.svg(
                xmlns: "http://www.w3.org/2000/svg",
                width: width,
                height: height,
              ) do
                elements.each_with_index do |element, index|
                  row = index / columns
                  col = index % columns

                  # Adjust the 'transform' attribute to position and scale the element in the grid
                  x =
                    col * (100 * scaling_factor + margin_left * scaling_factor) +
                    (width - 100 * scaling_factor) / 2
                  y = row * (100 * scaling_factor + margin_top * scaling_factor)

                  # Offset by half the size of the element vertically and horizontally
                  x += 50 * scaling_factor
                  y += 50 * scaling_factor

                  transform = "translate(#{x}, #{y}) scale(#{scaling_factor})"
                  element["transform"] = transform
                  xml.parent << element
                end
              end
            end

          combined_svg.to_xml
        end

        def write_svg(svg)
          puts svg
        end
      end
    end
  end
end
