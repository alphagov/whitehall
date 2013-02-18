# encoding: utf-8
require 'test_helper'

class HCardTest < ActiveSupport::TestCase

  test "renders address in UK format" do
    assert_equal gb_hcard, HCard.new(hcard_fields, 'GB').render
  end

  test "renders address in Spanish format" do
    assert_equal es_hcard, HCard.new(hcard_fields, 'ES').render
  end

  test "renders address in Japanese format" do
    assert_equal jp_hcard, HCard.new(hcard_fields, 'JP').render
  end

  test "doesn't clobber address formats" do
    gb_format_before = HCard.address_formats['gb'].dup

    HCard.new(hcard_fields, 'GB').render
    assert_equal gb_format_before, HCard.address_formats['gb']
  end

  test "blank properties do not render extra line breaks" do
    fields_without_region = hcard_fields
    fields_without_region.delete('region')
    assert_equal gb_hcard_without_region, HCard.new(fields_without_region, 'GB').render
  end

  def hcard_fields
    { 'fn' => 'Recipient',
      'street-address' => 'Street',
      'postal-code' => 'Postcode',
      'locality' => 'Locality',
      'region' => 'Region',
      'country-name' => 'Country'
    }
  end

  def gb_hcard
    <<-EOF.strip_heredoc
    <div class="vcard">
    <div class="adr">
    <span class="fn">Recipient</span><br />
    <span class="street-address">Street</span><br />
    <span class="locality">Locality</span><br />
    <span class="region">Region</span><br />
    <span class="postal-code">Postcode</span><br />
    <span class="country-name">Country</span>
    </div>
    </div>
    EOF
  end

  def es_hcard
    <<-EOF.strip_heredoc
    <div class="vcard">
    <div class="adr">
    <span class="fn">Recipient</span><br />
    <span class="street-address">Street</span><br />
    <span class="postal-code">Postcode</span> <span class="locality">Locality</span> <span class="region">Region</span><br />
    <span class="country-name">Country</span>
    </div>
    </div>
    EOF
  end

  def jp_hcard
    <<-EOF.strip_heredoc
    <div class="vcard">
    <div class="adr">
    〒<span class="postal-code">Postcode</span><br />
    <span class="region">Region</span><span class="locality">Locality</span><span class="street-address">Street</span><br />
    <span class="fn">Recipient</span><br />
    <span class="country-name">Country</span>
    </div>
    </div>
    EOF
  end

  def gb_hcard_without_region
    <<-EOF.strip_heredoc
    <div class="vcard">
    <div class="adr">
    <span class="fn">Recipient</span><br />
    <span class="street-address">Street</span><br />
    <span class="locality">Locality</span><br />
    <span class="postal-code">Postcode</span><br />
    <span class="country-name">Country</span>
    </div>
    </div>
    EOF
  end
end
