# frozen_string_literal: true

require "spec_helper"
require "./lib/svgr/document/resize"

RSpec.describe(Svgr::Document::Resize) do
  describe ".resize" do
    let(:width) { 210 }
    let(:height) { 285 }
    let(:argv) { [width, height] }
    let(:fixtures_path) { File.expand_path("../../../fixtures/coiledwall", __FILE__) }
    let(:input_svg) { File.read("#{fixtures_path}/take1.svg") }
    let(:output) { capture_stdout { described_class.start(argv) } }

    before do
      allow($stdin).to(receive(:read).and_return(input_svg))
    end

    it "resizes the document to the specified width and height" do
      doc = Nokogiri::XML(output)
      doc.remove_namespaces!
      svg_element = doc.at_xpath("//svg")

      # Calculate width and height in pixels using a DPI of 96
      width_px = (width * 96 / 25.4).round
      height_px = (height * 96 / 25.4).round

      expect(svg_element["width"].to_i).to(eq(width_px))
      expect(svg_element["height"].to_i).to(eq(height_px))
    end

    it "centers the elements within the resized document" do
      doc = Nokogiri::XML(output)
      doc.remove_namespaces!
      group_element = doc.at_xpath("//svg/g")

      transform = group_element["transform"]
      expect(transform).to(include("translate(#{397}, #{538})"))
    end
  end
end
