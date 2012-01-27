require 'test_helper'

class MapHelperTest < ActionView::TestCase
  test "should prefer latitude and longitude over postcode" do
    contact = build(:contact, latitude: 51.498772, longitude: -0.130974, postcode: "SW1H+0ET")
    html = link_to_google_map(contact)
    assert_select_in_html html, "a[href='http://maps.google.co.uk/maps?q=51.498772,-0.130974']"
  end

  test "should fallback to the postcode" do
    contact = build(:contact, postcode: "SW1H+0ET")
    html = link_to_google_map(contact)
    assert_select_in_html html, "a[href='http://maps.google.co.uk/maps?q=SW1H+0ET']"
  end

  test "should return nil if there is no latitude, longitude or postcode" do
    contact = build(:contact, latitude: nil, longitude: nil, postcode: nil)
    assert_nil link_to_google_map(contact)
  end

  test "should return nil if latitude, longitude or postcode are blank strings" do
    contact = build(:contact, latitude: "", longitude: "", postcode: "")
    assert_nil link_to_google_map(contact)
  end
end