require "test_helper"

class EmailSignupHelperTest < ActionView::TestCase
  def base_url
    "https://www.gov.uk/government/publications.atom"
  end

  test "#email_signup_path returns an email signup with the feed url" do
    result = email_signup_path(base_url)
    expected = "/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Fpublications.atom"

    assert_equal expected, result
  end

  test "#email_signup_path for 'open-consultations' returns the path with 'consultations'" do
    result = email_signup_path("#{base_url}?publication_filter_option=open-consultations")
    expected = "/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Fpublications.atom%3Fpublication_filter_option%3Dconsultations"

    assert_equal expected, result
  end

  test "#email_signup_path for 'closed-consultations' returns the path with 'consultations'" do
    result = email_signup_path("#{base_url}?publication_filter_option=closed-consultations")
    expected = "/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Fpublications.atom%3Fpublication_filter_option%3Dconsultations"

    assert_equal expected, result
  end

  test "#email_signup_path for 'consultations' returns the path with 'consultations'" do
    result = email_signup_path("#{base_url}?publication_filter_option=consultations")
    expected = "/government/email-signup/new?email_signup%5Bfeed%5D=https%3A%2F%2Fwww.gov.uk%2Fgovernment%2Fpublications.atom%3Fpublication_filter_option%3Dconsultations"

    assert_equal expected, result
  end
end
