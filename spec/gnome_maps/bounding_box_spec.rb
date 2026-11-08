# frozen_string_literal: true

# Ported from upstream's tests/boundingBoxTest.js, which tests
# src/boundingBox.js (this port's lib/gnome_maps/bounding_box.rb).

RSpec.describe GnomeMaps::BoundingBox do
  describe "#initialize" do
    it "takes top/left/bottom/right" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)

      expect(bbox.top).to eq(60.0)
      expect(bbox.left).to eq(15.0)
      expect(bbox.bottom).to eq(59.0)
      expect(bbox.right).to eq(16.0)
    end

    it "defaults to the box opposite of covering the whole world" do
      bbox = described_class.new

      expect(bbox.top).to eq(GnomeMaps::MIN_LATITUDE)
      expect(bbox.left).to eq(GnomeMaps::MAX_LONGITUDE)
      expect(bbox.bottom).to eq(GnomeMaps::MAX_LATITUDE)
      expect(bbox.right).to eq(GnomeMaps::MIN_LONGITUDE)
    end
  end

  describe "#copy" do
    it "is unaffected by later changes to the original" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)
      copy = bbox.copy

      bbox.top = 65.0
      bbox.left = 16.0
      bbox.bottom = 55.0
      bbox.right = 17.0

      expect(copy.top).to eq(60.0)
      expect(copy.left).to eq(15.0)
      expect(copy.bottom).to eq(59.0)
      expect(copy.right).to eq(16.0)
    end
  end

  describe "accessors" do
    it "can be set individually" do
      bbox = described_class.new
      bbox.top = 0
      bbox.left = 0
      bbox.bottom = -10
      bbox.right = 10

      expect(bbox.top).to eq(0.0)
      expect(bbox.left).to eq(0.0)
      expect(bbox.bottom).to eq(-10.0)
      expect(bbox.right).to eq(10.0)
    end
  end

  describe "#center" do
    it "returns [longitude, latitude] of the midpoint" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)

      expect(bbox.center).to eq([15.5, 59.5])
    end
  end

  describe "#compose" do
    it "extends the box to cover another box" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)
      other = described_class.new(top: 60.0, left: 14.0, bottom: 59.0, right: 15.0)

      bbox.compose(other)

      expect(bbox.top).to eq(60.0)
      expect(bbox.left).to eq(14.0)
      expect(bbox.bottom).to eq(59.0)
      expect(bbox.right).to eq(16.0)
    end
  end

  describe "#extend" do
    it "extends the box to cover a point" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)

      bbox.extend(58.0, 14.0)

      expect(bbox.top).to eq(60.0)
      expect(bbox.left).to eq(14.0)
      expect(bbox.bottom).to eq(58.0)
      expect(bbox.right).to eq(16.0)
    end
  end

  describe "#valid?" do
    it "is true for a sane box" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)

      expect(bbox.valid?).to be(true)
    end

    it "is false for the unset default box" do
      expect(described_class.new.valid?).to be(false)
    end

    it "is false when a bound overflows the world" do
      bbox = described_class.new(top: 100.0, left: 15.0, bottom: 0.0, right: 16.0)

      expect(bbox.valid?).to be(false)
    end

    it "is false when top/bottom or left/right are flipped" do
      bbox = described_class.new(top: 59.0, left: 16.0, bottom: 60.0, right: 15.0)

      expect(bbox.valid?).to be(false)
    end
  end

  describe "#covers?" do
    it "is true for a point inside the box" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)

      expect(bbox.covers?(59.5, 15.5)).to be(true)
    end

    it "is false for a point outside the box" do
      bbox = described_class.new(top: 60.0, left: 15.0, bottom: 59.0, right: 16.0)

      expect(bbox.covers?(0.0, 0.0)).to be(false)
      expect(bbox.covers?(59.0, -180.0)).to be(false)
    end
  end
end
