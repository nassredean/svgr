require "nokogiri"
require "optparse"

module Svgr
  class CombineSvgs
    def self.start(argv)
      options = {
        scaling_factor: 1,
        margin_top: 0,
        margin_left: 0,
        sort: "default"
      }

      opt_parser = OptionParser.new do |opts|
        opts.banner =
          "Usage: svgr combine [options] <source_directory> <rows> <columns>"

        opts.on(
          "-s",
          "--scaling-factor FACTOR",
          Float,
          "Scaling factor for the SVG elements"
        ) { |s| options[:scaling_factor] = s }

        opts.on(
          "-t",
          "--margin-top MARGIN",
          Integer,
          "Top margin between the SVG elements"
        ) { |t| options[:margin_top] = t }

        opts.on(
          "-l",
          "--margin-left MARGIN",
          Integer,
          "Left margin between the SVG elements"
        ) { |l| options[:margin_left] = l }

        opts.on(
          "--sort SORT",
          %w[default random],
          "Sorting option for the SVG files (default, random)"
        ) { |sort| options[:sort] = sort }

        opts.on(
          "--out FILE",
          "Specify an output file path"
        ) { |file| options[:out] = file }

        opts.on(
          "-h",
          "--help",
          "Prints this help"
        ) do
            puts opts
            exit
          end
      end
      opt_parser.parse!(argv)

      if argv.length < 3
        puts opt_parser.parse! %w[--help]
        exit(1)
      end

      source_directory, rows, columns = argv.shift(3)
      rows = rows.to_i
      columns = columns.to_i
      svg_files = list_svg_files(source_directory, options[:sort])[0...rows * columns]

      combined_elements = svg_files.flat_map do |file|
        content = read_svg_file(file)
        extract_svg_elements(content)
      end

      combined_svg = create_combined_svg(
        combined_elements,
        rows,
        columns,
        options[:scaling_factor],
        options[:margin_top],
        options[:margin_left]
      )

      write_svg(combined_svg, options[:out])
    end

    def self.list_svg_files(directory, sort_option)
      svg_files = Dir.glob(File.join(directory, "*.svg"))

      case sort_option
      when "default"
        svg_files.sort_by { |file| File.basename(file, ".svg").to_i }
      when "random"
        svg_files.shuffle
      else
        puts "Invalid sorting option. Allowed options: default, random"
        exit(1)
      end
    end

    def self.read_svg_file(file)
      File.read(file)
    end

    def self.extract_svg_elements(svg_content)
      doc = Nokogiri.XML(svg_content)
      doc.remove_namespaces!
      top_level_groups = doc.xpath("//svg/g")

      if top_level_groups.empty?
        # Wrap all child elements of the SVG document in a group
        svg_element = doc.at_xpath("//svg")
        new_group = Nokogiri::XML::Node.new("g", doc)

        svg_element.children.each do |child|
          new_group.add_child(child)
        end

        svg_element.add_child(new_group)
        top_level_groups = [new_group]
      end

      top_level_groups
    end

    def self.create_combined_svg(
      elements,
      rows,
      columns,
      scaling_factor,
      margin_top,
      margin_left
    )
      combined_svg =
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.svg(xmlns: "http://www.w3.org/2000/svg") do
            elements.each_with_index do |element, index|
              row = index / columns
              col = index % columns

              # Adjust the 'transform' attribute to position and scale the element in the grid
              transform =
                "translate(#{col * (100 + margin_left) * scaling_factor}, #{row * (100 + margin_top) * scaling_factor}) scale(#{scaling_factor})"
              element["transform"] = transform
              xml << element.to_xml
            end
          end
        end
      combined_svg.to_xml
    end


    def self.write_svg(svg, output_file = nil)
      if output_file
        File.write(output_file, svg)
      else
        puts svg
      end
    end
  end
end
