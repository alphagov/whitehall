require "test_helper"

class LogoHelperTest < ActionView::TestCase
  test 'given an organisation should return suitable org-identifying logo class names' do
    assert_equal 'organisation-logo organisation-logo-single-identity',
        logo_classes(class_name: OrganisationLogoType::SingleIdentity.class_name)
    assert_equal 'organisation-logo organisation-logo-no-identity',
        logo_classes(class_name: OrganisationLogoType::NoIdentity.class_name)
  end
end
