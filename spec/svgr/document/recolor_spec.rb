# frozen_string_literal: true

require "spec_helper"
require "./lib/svgr/document/recolor"

RSpec.describe(Svgr::Document::Recolor) do
  describe ".recolored" do
    let(:hex_value) { "#FF5733" }
    let(:argv) { [hex_value] }
    let(:fixtures_path) { File.expand_path("../../../fixtures/coiledwall", __FILE__) }
    let(:input_svg) { File.read("#{fixtures_path}/take1.svg") }
    let(:output) { capture_stdout { described_class.start(argv) } }

    before do
      allow($stdin).to(receive(:read).and_return(input_svg))
    end

    it "recolors elements with a fill attribute" do
      doc = Nokogiri::XML(output)
      doc.remove_namespaces!
      elements_with_fill = doc.xpath("//svg/*[@fill]")

      elements_with_fill.each do |element|
        expect(element["fill"]).to eq(hex_value)
      end
    end

    it "recolors elements with a stroke attribute" do
      doc = Nokogiri::XML(output)
      doc.remove_namespaces!
      elements_with_stroke = doc.xpath("//svg/*[@stroke]")

      elements_with_stroke.each do |element|
        expect(element["stroke"]).to eq(hex_value)
      end
    end

    it "does not recolor elements without a fill or stroke attribute" do
      doc = Nokogiri::XML(output)
      doc.remove_namespaces!
      elements_without_fill_or_stroke = doc.xpath("//svg/*[not(@fill) and not(@stroke)]")

      elements_without_fill_or_stroke.each do |element|
        expect(element["fill"]).to be_nil
        expect(element["stroke"]).to be_nil
      end
    end
  end
end
