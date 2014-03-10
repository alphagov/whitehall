require 'gds_api/test_helpers/content_api'

module SpecialistSectorHelper
  include GdsApi::TestHelpers::ContentApi

  def stub_specialist_sectors
    parent_tag = { slug: 'oil-and-gas', title: 'Oil and Gas' }
    sector_tags = [
      parent_tag,
      { slug: 'oil-and-gas/wells', title: 'Wells', parent: parent_tag },
      { slug: 'oil-and-gas/fields', title: 'Fields', parent: parent_tag },
      { slug: 'oil-and-gas/offshore', title: 'Offshore', parent: parent_tag }
    ]

    content_api_has_tags('specialist_sector', sector_tags)
  end

  def select_specialist_sectors_in_form
    select 'Oil and Gas: Wells', from: 'Primary specialist sector'
    select 'Oil and Gas: Offshore', from: 'Additional specialist sectors'
    select 'Oil and Gas: Fields', from: 'Additional specialist sectors'
  end

  def assert_specialist_sectors_were_saved
    assert has_css?('.flash.notice')
    click_on 'Edit draft'
    assert_equal 'oil-and-gas/wells', find_field('Primary specialist sector').value
    assert_equal ['oil-and-gas/offshore', 'oil-and-gas/fields'].to_set, find_field('Additional specialist sectors').value.to_set
  end

  def save_document
    click_button 'Save'
  end
end

World(SpecialistSectorHelper)
