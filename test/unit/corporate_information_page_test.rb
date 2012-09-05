require "test_helper"

class CorporateInformationPageTest < ActiveSupport::TestCase

  def self.should_be_invalid_without(type, attribute_name)
    test "#{type} should be invalid without #{attribute_name}" do
      document = build(type, attribute_name => nil)
      refute document.valid?
    end
  end

  should_be_invalid_without(:corporate_information_page, :type)
  should_be_invalid_without(:corporate_information_page, :body)
  should_be_invalid_without(:corporate_information_page, :organisation)

  test "should derive title from type" do
    corporate_information_page = build(:corporate_information_page, type: CorporateInformationPageType::TermsOfReference)
    assert_equal "Terms of reference", corporate_information_page.title
  end

  test "should derive slug from type" do
    corporate_information_page = build(:corporate_information_page, type: CorporateInformationPageType::TermsOfReference)
    assert_equal "terms-of-reference", corporate_information_page.slug
  end
end