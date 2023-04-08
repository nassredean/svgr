# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/svgr/combine_svgs"

RSpec.describe(Svgr::CombineSvgs) do
  let(:fixtures_path) { File.expand_path("../fixtures/coiledwall", __dir__) }

  describe ".start" do
    let(:rows) { 1 }
    let(:columns) { 3 }
    let(:argv) { [fixtures_path, rows, columns] }

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
          fixtures_path,
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

    context "when sort option is specified" do
      let(:sort_option) { "random" }
      let(:argv) do
        [fixtures_path, rows.to_s, columns.to_s, "--sort", sort_option]
      end

      it "sorts the SVGs using the specified option" do
        # Run the command multiple times to check for randomness
        outputs = []
        5.times { outputs << capture_stdout { described_class.start(argv) } }

        # Check if the outputs are different, indicating randomness
        unique_outputs = outputs.uniq
        expect(unique_outputs.length).to(be > 1)
      end
    end
  end
end

def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_stdout
end
