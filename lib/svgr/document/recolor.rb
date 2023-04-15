# frozen_string_literal: true

require "nokogiri"

module Svgr
  module Document
    class Recolor
      class << self
        def start(argv)
          hex_value = argv[0]

          if !hex_value || argv.size != 1
            puts "Usage: svgr document:recolor <HEXVALUE>"
            exit(1)
          end

          svg_content = $stdin.read
          recolored_svg = recolor(svg_content, hex_value)

          # Write the output
          output = recolored_svg.to_xml
          puts output
        end

        def recolor(content, hex_value)
          svg = Nokogiri::XML(content)
          svg.css("path, circle, ellipse, line, polyline, polygon, rect").each do |element|
            element["fill"] = hex_value if element["fill"] && element["fill"] != "none"
            element["stroke"] = hex_value if element["stroke"] && element["stroke"] != "none"
          end
          svg
        end
      end
    end
  end
end
