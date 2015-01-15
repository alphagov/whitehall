require "test_helper"

class EmailSignupPagesFinderTest < ActiveSupport::TestCase

  test "returns correct OpenStruct" do
    @signup_page = EmailSignupPagesFinder.signup_page_for_atom_url("medicines-and-healthcare-products-regulatory-agency.atom")

    assert_equal @signup_page.email_signup_path, "/government/organisations/medicines-and-healthcare-products-regulatory-agency/email-signup"
    assert_equal @signup_page.signup_pages.length, 3
  end

  test "doesn't match other URLs" do
    @signup_page = EmailSignupPagesFinder.signup_page_for_atom_url("ministry-of-silly-walks.atom")

    assert_equal @signup_page, nil
  end

end
