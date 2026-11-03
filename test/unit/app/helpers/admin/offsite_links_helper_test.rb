require "test_helper"

class Admin::OffsiteLinksHelperTest < ActionView::TestCase
  test "#offsite_link_date_enabled? is true for organisations and world location news" do
    assert offsite_link_date_enabled?(build(:organisation))
    assert offsite_link_date_enabled?(build(:world_location_news))
  end

  test "#offsite_link_date_enabled? is false for topical events" do
    assert_not offsite_link_date_enabled?(build(:standard_edition))
    assert_not offsite_link_date_enabled?(build(:topical_event))
  end
end
