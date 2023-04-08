require "spec_helper"
require_relative "../lib/svgr/combine_svgs"

RSpec.describe Svgr::CombineSvgs do
  let(:fixtures_path) { File.expand_path("../fixtures/coiledwall", __FILE__) }

  describe ".start" do
    let(:rows) { 1 }
    let(:columns) { 3 }
    let(:argv) { [fixtures_path, rows, columns] }

    let(:output) do
      capture_stdout { Svgr::CombineSvgs.start(argv) }
    end

    it "combines the specified number of SVGs" do
      doc = Nokogiri::XML(output)
      doc.remove_namespaces!
      combined_elements = doc.xpath("//svg/g") 
      expect(combined_elements.size).to eq(rows * columns)
    end

    context "when margin options are specified" do
      let(:margin_top) { 10 }
      let(:margin_left) { 20 }
      let(:argv) do
        [fixtures_path, rows.to_s, columns.to_s, "--margin-top", margin_top.to_s, "--margin-left", margin_left.to_s]
      end

      it "applies the specified margin options to the combined SVG" do
        doc = Nokogiri::XML(output)
        doc.remove_namespaces!
        combined_elements = doc.xpath("//svg/g")

        combined_elements.each_with_index do |element, index|
          row = index / columns
          col = index % columns

          transform = element["transform"]
          expected_transform = "translate(#{col * (100 + margin_left)}, #{row * (100 + margin_top)})"

          expect(transform).to include(expected_transform)
        end
      end
    end

    context "when sort option is specified" do
      let(:sort_option) { "random" }
      let(:argv) { [fixtures_path, rows.to_s, columns.to_s, "--sort", sort_option] }

      it "sorts the SVGs using the specified option" do
        # Run the command multiple times to check for randomness
        outputs = []
        3.times do
          outputs << capture_stdout { Svgr::CombineSvgs.start(argv) }
        end

        # Check if the outputs are different, indicating randomness
        unique_outputs = outputs.uniq
        expect(unique_outputs.length).to be > 1
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
