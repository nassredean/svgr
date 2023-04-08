# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/svgr/document_resize"

RSpec.describe(Svgr::DocumentResize) do
  let(:fixtures_path) { File.expand_path("../../fixtures/coiledwall", __FILE__) }
  let(:input_svg) { File.read("#{fixtures_path}/take1.svg") }

  describe ".resize" do
    let(:width) { 210 }
    let(:height) { 285 }

    let(:resized_svg) do
      described_class.resize(input_svg, width, height)
    end

    it "resizes the document to the specified width and height" do
      doc = Nokogiri::XML(resized_svg)
      doc.remove_namespaces!
      svg_element = doc.at_xpath("//svg")

      width_px = (width * 96 / 25.4).round
      height_px = (height * 96 / 25.4).round

      expect(svg_element["width"].to_i).to(eq(width_px))
      expect(svg_element["height"].to_i).to(eq(height_px))
    end

    it "centers the elements within the resized document" do
      doc = Nokogiri::XML(resized_svg)
      doc.remove_namespaces!
      group_element = doc.at_xpath("//svg/g")

      transform = group_element["transform"]
      expected_translate_x = ((width * 96 / 25.4) - 300) / 2
      expected_translate_y = ((height * 96 / 25.4) - 100) / 2

      expect(transform).to(include("translate(#{expected_translate_x}, #{expected_translate_y})"))
    end
  end
end
