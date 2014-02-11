require 'test_helper'
require 'gds_api/test_helpers/content_api'

class SpecialistSectorTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentApi

  test '.options_for_select should return specialist sector tags ready for use as grouped options' do
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

    content_api_has_tags('industry_sectors', sector_tags)

    expected_options = [
      ['Oil and Gas', [['Oil and Gas: Wells', 'oil-and-gas/wells'],
                       ['Oil and Gas: Fields', 'oil-and-gas/fields']]],
      ['Tax', [['Tax: Income Tax', 'tax/income-tax'],
               ['Tax: Capital Gains Tax', 'tax/capital-gains-tax']]]
    ]

    assert_equal expected_options, SpecialistSector.options_for_select
  end
end
