require 'test_helper'
require 'gds_api/test_helpers/content_api'

class SpecialistSectorTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentApi

  setup do
    use_real_content_api
  end

  teardown do
    use_fake_content_api
  end

  test '.grouped_sector_topics should return specialist sector tags grouped under parents' do
    oil_and_gas = { slug: 'oil-and-gas', title: 'Oil and Gas' }
    tax = { slug: 'tax', title: 'Tax' }

    sector_tags = [
      oil_and_gas,
      { slug: 'oil-and-gas/wells', title: 'Wells', parent: oil_and_gas },
      { slug: 'oil-and-gas/fields', title: 'Fields', parent: oil_and_gas },
      tax,
      { slug: 'tax/income-tax', title: 'Income Tax', parent: tax },
      { slug: 'tax/capital-gains-tax', title: 'Capital Gains Tax', parent: tax }
    ]

    content_api_has_tags('specialist_sectors', sector_tags)

    oil_and_gas = OpenStruct.new(
      slug: 'oil-and-gas',
      title: 'Oil and Gas',
      topics: [
        OpenStruct.new(slug: 'oil-and-gas/wells', title: 'Wells'),
        OpenStruct.new(slug: 'oil-and-gas/fields', title: 'Fields')
      ]
    )

    tax = OpenStruct.new(
      slug: 'tax',
      title: 'Tax',
      topics: [
        OpenStruct.new(slug: 'tax/income-tax', title: 'Income Tax'),
        OpenStruct.new(slug: 'tax/capital-gains-tax', title: 'Capital Gains Tax')
      ]
    )

    assert_equal [oil_and_gas, tax], SpecialistSector.grouped_sector_topics
  end

  test '.grouped_sector_topics should raise a DataUnavailable error when the content API is unavailable' do
    GdsApi::ContentApi.any_instance.stubs(:tags).raises(GdsApi::HTTPErrorResponse.new(500, 'Error'))

    assert_raise SpecialistSector::DataUnavailable do
      SpecialistSector.grouped_sector_topics
    end
  end

private
  def use_real_content_api
    Whitehall.content_api = GdsApi::ContentApi.new(Plek.current.find('content_api'))
  end

  def use_fake_content_api
    Whitehall.content_api = GdsApi::ContentApi::Fake.new
  end
end
