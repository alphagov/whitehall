require "test_helper"

class EmailSignupHelperTest < ActionView::TestCase
  test "#email_signup_path returns an email-alert-frontend signup url" do
    atom_feed_url = "https://www.gov.uk/government/people/boris-johnson.atom"
    result = email_signup_path(atom_feed_url)
    expected = "https://www.test.gov.uk/email-signup?link=/government/people/boris-johnson"
    assert_equal expected, result
  end

  test "#email_signup_path returns a signup path for mhra" do
    atom_feed_url = "https://www.gov.uk/government/organisations/medicines-and-healthcare-products-regulatory-agency.atom"
    result = email_signup_path(atom_feed_url)
    expected = "/government/organisations/medicines-and-healthcare-products-regulatory-agency/email-signup"
    assert_equal expected, result
  end
end
