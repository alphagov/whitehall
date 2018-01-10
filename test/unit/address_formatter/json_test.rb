# encoding: utf-8

require 'fast_test_helper'
require 'address_formatter/json'
require 'active_support/core_ext/string' # for strip_heredoc

class AddressFormatter::JsonTest < ActiveSupport::TestCase
  setup do
    @old_formats = AddressFormatter::Formatter.address_formats
    AddressFormatter::Formatter.address_formats = YAML.safe_load(%{
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

  test "renders a json hash with all contact elements in a adr key" do
    expected_adr_hash = {
      'fn' => 'Recipient',
      'street-address' => 'Street',
      'postal-code' => 'Postcode',
      'locality' => 'Locality',
      'region' => 'Region',
      'country-name' => 'Country'
    }

    address = AddressFormatter::Json.new(addr_fields, 'GB').render['address']
    assert_equal expected_adr_hash, address['adr']
  end

  test "renders a json hash with all contact elements in a adr key, regardless of country code" do
    expected_adr_hash = {
      'fn' => 'Recipient',
      'street-address' => 'Street',
      'postal-code' => 'Postcode',
      'locality' => 'Locality',
      'region' => 'Region',
      'country-name' => 'Country'
    }

    address = AddressFormatter::Json.new(addr_fields, 'JP').render['address']
    assert_equal expected_adr_hash, address['adr']
  end

  test "includes blank string values for missing fields in the adr hash" do
    fields = addr_fields.dup
    fields['region'] = nil

    address = AddressFormatter::Json.new(fields, 'JP').render['address']
    assert_equal '', address['adr']['region']

    fields['region'] = ' '

    address = AddressFormatter::Json.new(fields, 'JP').render['address']
    assert_equal '', address['adr']['region']

    fields.delete('region')

    address = AddressFormatter::Json.new(fields, 'JP').render['address']
    assert_equal '', address['adr']['region']
  end

  test "includes a text representation of the address in the label hash value key" do
    address = AddressFormatter::Json.new(addr_fields, 'GB').render['address']
    assert_equal gb_label, address['label']['value']
  end

  test "includes a text representation of the address, using the country code, in the label hash value key" do
    address = AddressFormatter::Json.new(addr_fields, 'JP').render['address']
    assert_equal jp_label, address['label']['value']
  end

  test "has no type key in the adr hash unless specified" do
    address = AddressFormatter::Json.new(addr_fields, 'JP').render['address']
    refute address['adr'].has_key?('type')
  end

  test "includes a type key in the adr hash if specificed" do
    address = AddressFormatter::Json.new(addr_fields, 'JP').render('office')['address']
    assert_equal 'office', address['adr']['type']
  end

  test "has no type key in the label hash unless specified" do
    address = AddressFormatter::Json.new(addr_fields, 'JP').render['address']
    refute address['label'].has_key?('type')
  end

  test "includes a type key in the label hash if specificed" do
    address = AddressFormatter::Json.new(addr_fields, 'JP').render('office')['address']
    assert_equal 'office', address['label']['type']
  end

  def addr_fields
    {
      'fn' => 'Recipient',
      'street-address' => 'Street',
      'postal-code' => 'Postcode',
      'locality' => 'Locality',
      'region' => 'Region',
      'country-name' => 'Country'
    }
  end

  def gb_label
    <<-EOF.strip_heredoc.chomp
    Recipient
    Street
    Locality
    Region
    Postcode
    Country
    EOF
  end

  def jp_label
    <<-EOF.strip_heredoc.chomp
    〒Postcode
    RegionLocalityStreet
    Recipient
    Country
    EOF
  end
end
