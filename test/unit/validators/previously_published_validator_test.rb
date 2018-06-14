require "test_helper"

class PreviouslyPublishedValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = PreviouslyPublishedValidator.new
  end

  test "invalid if previously_published is nil" do
    invalid_edition = Edition.new
    @validator.validate(invalid_edition)
    assert_equal "You must specify whether the document has been published before",
      invalid_edition.errors[:base].first
  end

  test "no-op unless record can be previously published" do
    edition = build(:consultation)
    @validator.validate(edition)
    assert edition.errors.empty?, "No errors were expected"
  end

  test "invalid if first_published_at is nil" do
    invalid_edition = build(:edition, previously_published: true, first_published_at: nil)
    @validator.validate(invalid_edition)
    assert_equal "can't be blank",
      invalid_edition.errors[:first_published_at].first
  end

  test "valid if first_published_at is in the past" do
    valid_edition = build(:edition, previously_published: true, first_published_at: 1.hour.ago)
    @validator.validate(valid_edition)
    assert valid_edition.valid?
  end
end
