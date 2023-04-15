# frozen_string_literal: true

require "spec_helper"
require "./lib/svgr/arrange/grid"

RSpec.describe(Svgr::Arrange::Grid) do
  let(:fixtures_path) { File.expand_path("../../fixtures/coiledwall", __dir__) }

  describe ".start" do
    let(:rows) { 1 }
    let(:columns) { 3 }
    let(:file_paths) { Dir.glob(File.join(fixtures_path, "*.svg")).first(3).join(",") }
    let(:argv) { [file_paths, rows, columns] }
    let(:output) { capture_stdout { described_class.start(argv) } }

    it "combines the specified number of SVGs" do
      doc = Nokogiri.XML(output)
      doc.remove_namespaces!
      combined_elements = doc.xpath("//svg/g")
      expect(combined_elements.size).to(eq(rows * columns))
    end

    context "when margin options are specified" do
      let(:margin_top) { 10 }
      let(:margin_left) { 20 }
      let(:argv) do
        [
          file_paths,
          rows.to_s,
          columns.to_s,
          "--margin-top",
          margin_top.to_s,
          "--margin-left",
          margin_left.to_s,
        ]
      end

      it "applies the specified margin options to the combined SVG" do
        doc = Nokogiri.XML(output)
        doc.remove_namespaces!
        combined_elements = doc.xpath("//svg/g")

        combined_elements.each_with_index do |element, index|
          row = index / columns
          col = index % columns

          x =
            col * (100 + margin_left) + (doc.root["width"].to_f - 100) / 2 + 50
          y = row * (100 + margin_top) + 50

          transform = element["transform"]
          expected_transform = "translate(#{x.to_i}, #{y.to_i})"

          expect(transform).to(include(expected_transform))
        end
      end
    end
  end
end
