require "test_helper"

class CaseStudyTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_protect_against_xss_and_content_attacks_on :landing_page, :body

  test "landing-page base_path is not overwritten from title" do
    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:)
    assert_equal landing_page.base_path, "/landing-page/test"
  end
end