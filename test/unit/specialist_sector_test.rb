require 'test_helper'
require 'gds_api/test_helpers/content_api'

class SpecialistSectorTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentApi

  setup do
    use_real_content_api

    oil_and_gas = { slug: 'oil-and-gas', title: 'Oil and Gas', draft: false }
    tax = { slug: 'tax', title: 'Tax', draft: false }
    environmental_management = { slug: 'environmental-management', title: 'Environmental management', draft: true }

    draft_sector_tags = [
      { slug: 'tax/capital-gains-tax', title: 'Capital Gains Tax', parent: tax, draft: true },
      { slug: 'oil-and-gas/wells', title: 'Wells', parent: oil_and_gas, draft: true },
      environmental_management
    ]

    live_sector_tags = [
      tax,
      { slug: 'tax/income-tax', title: 'Income Tax', parent: tax, draft: false },
      oil_and_gas,
      { slug: 'oil-and-gas/fields', title: 'Fields', parent: oil_and_gas, draft: false }
    ]

    content_api_has_draft_and_live_tags(type: 'specialist_sector', draft: draft_sector_tags, live: live_sector_tags)


    @wells = OpenStruct.new(slug: 'oil-and-gas/wells', title: 'Wells', draft?: true, topics: [])
    @fields = OpenStruct.new(slug: 'oil-and-gas/fields', title: 'Fields', draft?: false, topics: [])

    @oil_and_gas = OpenStruct.new(
      slug: 'oil-and-gas',
      title: 'Oil and Gas',
      draft?: false,
      topics: [
        @fields,
        @wells
      ]
    )

    @income_tax = OpenStruct.new(slug: 'tax/income-tax', title: 'Income Tax', draft?: false, topics: [])
    @capital_gains = OpenStruct.new(slug: 'tax/capital-gains-tax', title: 'Capital Gains Tax', draft?: true, topics: [])

    @tax = OpenStruct.new(
      slug: 'tax',
      title: 'Tax',
      draft?: false,
      topics: [
        @income_tax,
        @capital_gains
      ]
    )

    @environmental_management = OpenStruct.new(
      slug: 'environmental-management',
      title: 'Environmental management',
      draft?: true,
      topics: []
    )
  end

  teardown do
    use_fake_content_api
  end

  test '.grouped_sector_topics should return specialist sector tags grouped under sorted parents' do
    assert_equal [@oil_and_gas, @tax], SpecialistSector.grouped_sector_topics
  end

  test '.grouped_sector_topics should raise a DataUnavailable error when the content API is unavailable' do
    GdsApi::ContentApi.any_instance.stubs(:tags).raises(GdsApi::HTTPErrorResponse.new(500, 'Error'))

    assert_raise SpecialistSector::DataUnavailable do
      SpecialistSector.grouped_sector_topics
    end
  end

  test '.live_subsectors should return only live subsectors' do
    assert_equal [@income_tax, @fields], SpecialistSector.live_subsectors
  end

  test '.live_subsectors should cache bust the Content API request' do
    SpecialistSector.live_subsectors

    assert_requested :get, Regexp.new("#{Plek.find('content_api')}.*\\?(.*&)?cachebust=")
  end

private
  def use_real_content_api
    Whitehall.content_api = GdsApi::ContentApi.new(Plek.find('content_api'))
  end

  def use_fake_content_api
    Whitehall.content_api = GdsApi::ContentApi::Fake.new
  end
end
