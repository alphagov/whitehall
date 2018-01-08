# encoding: utf-8

require 'fast_test_helper'
require 'address_formatter/text'
require 'active_support/core_ext/string' # for strip_heredoc
require 'ostruct'

class AddressFormatter::TextTest < ActiveSupport::TestCase
  setup do
    @old_formats = AddressFormatter::Formatter.address_formats
    AddressFormatter::Formatter.address_formats = YAML.load(%{
      es: |-
          {{fn}}
          {{street-address}}
          {{postal-code}} {{locality}} {{region}}
          {{country-name}}
      gb: |-
          {{fn}}
          {{street-address}}
          {{locality}}
          {{region}}
          {{postal-code}}
          {{country-name}}
      jp: |-
          〒{{postal-code}}
          {{region}}{{locality}}{{street-address}}
          {{fn}}
          {{country-name}}
    })
  end
  teardown do
    AddressFormatter::Formatter.address_formats = @old_formats
  end

  test "renders address in UK format" do
    assert_equal gb_addr, AddressFormatter::Text.new(addr_fields, 'GB').render
  end

  test "renders address in Spanish format" do
    assert_equal es_addr, AddressFormatter::Text.new(addr_fields, 'ES').render
  end

  test "renders address in Japanese format" do
    assert_equal jp_addr, AddressFormatter::Text.new(addr_fields, 'JP').render
  end

  test "doesn't clobber address formats" do
    gb_format_before = AddressFormatter::Formatter.address_formats['gb'].dup
    AddressFormatter::Text.new(addr_fields, 'GB').render

    assert_equal gb_format_before, AddressFormatter::Formatter.address_formats['gb']
  end

  test "blank properties do not render extra line breaks" do
    fields_without_region = addr_fields
    fields_without_region.delete('region')

    assert_equal addr_without_region, AddressFormatter::Text.new(fields_without_region, 'GB').render

    fields_without_recipient = addr_fields
    fields_without_recipient.delete('fn')

    rendered = AddressFormatter::Text.new(fields_without_recipient, 'GB').render
    assert rendered !~ /\A\n/, 'expected not to start with a blank line'

    fields_without_country = addr_fields
    fields_without_country.delete('country-name')

    rendered = AddressFormatter::Text.new(fields_without_country, 'GB').render
    assert rendered !~ /\n\Z/, 'expected not to end with a blank line'
  end

  test "doesn't render a property when it's a blank string" do
    fields = addr_fields

    fields['region'] = ''
    assert_equal addr_without_region, AddressFormatter::Text.new(fields, 'GB').render

    fields['region'] = '   '
    assert_equal addr_without_region, AddressFormatter::Text.new(fields, 'GB').render
  end

  test "it defaults to UK format" do
    assert_equal gb_addr, AddressFormatter::Text.new(addr_fields, 'FUBAR').render
  end

  test "it builds from a Contact" do
    contact = OpenStruct.new(recipient: 'Recipient',
                             street_address: 'Street',
                             locality: 'Locality',
                             region: 'Region',
                             postal_code: 'Postcode',
                             country_name: 'Country',
                             country_code: 'ES')
    hcard = AddressFormatter::Text.from_contact(contact)

    assert_equal es_addr, hcard.render
  end

  test "it leaves out the country name when building a GB contact" do
    contact = OpenStruct.new(recipient: 'Recipient',
                             street_address: 'Street',
                             locality: 'Locality',
                             region: 'Region',
                             postal_code: 'Postcode',
                             country_name: 'Country',
                             country_code: 'GB')
    hcard = AddressFormatter::Text.from_contact(contact)

    assert_equal addr_without_country, hcard.render
  end

  def addr_fields
    { 'fn' => 'Recipient',
      'street-address' => 'Street',
      'postal-code' => 'Postcode',
      'locality' => 'Locality',
      'region' => 'Region',
      'country-name' => 'Country'
    }
  end

  def gb_addr
    <<-EOF.strip_heredoc.chomp
    Recipient
    Street
    Locality
    Region
    Postcode
    Country
    EOF
  end

  def es_addr
    <<-EOF.strip_heredoc.chomp
    Recipient
    Street
    Postcode Locality Region
    Country
    EOF
  end

  def jp_addr
    <<-EOF.strip_heredoc.chomp
    〒Postcode
    RegionLocalityStreet
    Recipient
    Country
    EOF
  end

  def addr_without_region
    <<-EOF.strip_heredoc.chomp
    Recipient
    Street
    Locality
    Postcode
    Country
    EOF
  end

  def addr_without_country
    <<-EOF.strip_heredoc.chomp
    Recipient
    Street
    Locality
    Region
    Postcode
    EOF
  end
end
