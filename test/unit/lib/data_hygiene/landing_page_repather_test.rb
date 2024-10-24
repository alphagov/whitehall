require "test_helper"

class LandingPageRepatherTest < ActiveSupport::TestCase
  setup do
    stub_any_publishing_api_call
    @user = create(:user)
    @document = create(:document, slug: "/old/path", document_type: "landing_page")
    @published_edition = create(:searchable_edition, :published)
  end

  test "returns false and the adds an error to the document when new_slug does not start with a slash" do
    repather = DataHygiene::LandingPageRepather.new(@document, @published_edition, @user, "invalid-slug")
    assert_equal false, repather.run!
    assert_equal @document.errors.full_messages, ["Slug must start with a slash"]
  end
end
