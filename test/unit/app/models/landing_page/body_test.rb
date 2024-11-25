require "test_helper"

class LandingPageBodyTest < ActiveSupport::TestCase
  test "is invalid with empty YAML" do
    subject = LandingPage::Body.new("")
    assert subject.invalid?
    assert_equal ["Blocks can't be blank"], subject.errors.to_a
  end

  test "is invalid with empty blocks" do
    subject = LandingPage::Body.new(<<~YAML)
      blocks: []
    YAML
    assert subject.invalid?
    assert_equal ["Blocks can't be blank"], subject.errors.to_a
  end

  test "is valid with a single unknown block in YAML" do
    subject = LandingPage::Body.new(<<~YAML)
      blocks:
      - type: unknown
    YAML
    assert subject.valid?
  end

  test "is valid with all parameters provided" do
    subject = LandingPage::Body.new(<<~YAML)
      navigation_groups: []
      breadcrumbs: []
      blocks:
      - type: unknown
    YAML
    assert subject.valid?
    assert_equal [], subject.navigation_groups
    assert_equal [], subject.breadcrumbs
    assert_equal 1, subject.blocks.length
    assert_equal({
      navigation_groups: [],
      breadcrumbs: [],
      blocks: [
        { type: "unknown" },
      ],
    }, subject.present_for_publishing_api.deep_symbolize_keys)
  end

  test "presents to publishing-api" do
    subject = LandingPage::Body.new(<<~YAML)
      navigation_groups: []
      breadcrumbs: []
      blocks:
      - type: unknown
    YAML
    result = subject.present_for_publishing_api
    assert_equal({
      navigation_groups: [],
      breadcrumbs: [],
      blocks: [
        { type: "unknown" },
      ],
    }, result.deep_symbolize_keys)
  end

  test "extends a document which does exist" do
    edition = create(:edition, body: "navigation_groups: []")
    subject = LandingPage::Body.new(<<~YAML)
      extends: #{edition.slug}
      blocks:
      - type: unknown
    YAML
    assert subject.valid?
    assert_equal [], subject.navigation_groups
  end

  test "is invalid when extending a document which does not exist" do
    subject = LandingPage::Body.new(<<~YAML)
      extends: /some-document-which-does-not-exist
      blocks:
      - type: unknown
    YAML
    assert subject.invalid?
    assert_equal [
      "Body extends /some-document-which-does-not-exist but that document does not exist, or does not have a YAML body",
    ], subject.errors.to_a
  end
end
