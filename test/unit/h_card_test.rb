require 'test_helper'

class HCardTest < ActiveSupport::TestCase

  test "renders addreses in UK format" do
    h_card = HCard.new(hcard_fields, 'GB')

    assert_equal gb_hcard, h_card.render
  end

  def hcard_fields
    { 'fn' => 'Department for Business, Innovation and Skills',
      'street-address' => '1 Victoria Street',
      'postal-code' => 'SW1H 0ET',
      'locality' => 'London',
      'region' => 'Greater London',
      'country-name' => 'United Kingdom'
    }
  end

  def gb_hcard
'<div class="vcard">
  <div class="adr">
    <span class="fn">Department for Business, Innovation and Skills</span><br />
    <span class="street-address">1 Victoria Street</span><br />
    <span class="postal-code">SW1H 0ET</span><br />
    <span class="locality">London</span><br />
    <span class="region">Greater London</span><br />
    <span class="country-name">United Kingdom</span>
  </div>
</div>'
  end
end
