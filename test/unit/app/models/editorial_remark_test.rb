require "test_helper"

class EditorialRemarkTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:edition_id) { 5 }
  let(:edition) { build(:edition, id: edition_id) }
  let(:editorial_remark) { build(:editorial_remark, edition:) }

  describe "#valid?" do
    it "should be invalid without a edition" do
      editorial_remark.edition = nil
      assert_not editorial_remark.valid?
    end

    it "should be invalid without a body" do
      editorial_remark.body = nil
      assert_not editorial_remark.valid?
    end

    it "should be invalid without an author" do
      editorial_remark.author = nil
      assert_not editorial_remark.valid?
    end
  end

  describe "#is_for_newer_edition?" do
    it "returns true if the edition_id is less than the comparing edition's id" do
      edition_to_compare = build(:edition, id: edition_id - 1)
      assert editorial_remark.is_for_newer_edition?(edition_to_compare)
    end

    it "returns false if the edition_id is greater than the comparing edition's id" do
      edition_to_compare = build(:edition, id: edition_id + 1)
      assert_not editorial_remark.is_for_newer_edition?(edition_to_compare)
    end
  end

  describe "#is_for_current_edition?" do
    it "returns true if the edition_id is equal to the comparing edition's id" do
      edition_to_compare = build(:edition, id: edition_id)
      assert editorial_remark.is_for_current_edition?(edition_to_compare)
    end

    it "returns false if the edition_id is not equal to the comparing edition's id" do
      edition_to_compare = build(:edition, id: edition_id + 1)
      assert_not editorial_remark.is_for_current_edition?(edition_to_compare)
    end
  end

  describe "#is_for_older_edition?" do
    it "returns true if the edition_id is greater than the comparing edition's id" do
      edition_to_compare = build(:edition, id: edition_id + 1)
      assert editorial_remark.is_for_older_edition?(edition_to_compare)
    end

    it "returns true if the edition_id is less than the comparing edition's id" do
      edition_to_compare = build(:edition, id: edition_id - 1)
      assert_not editorial_remark.is_for_older_edition?(edition_to_compare)
    end
  end
end
