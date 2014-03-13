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

  def stub_content_api_tags(document)
    artefact_slug = RegisterableEdition.new(document).slug
    tag_slugs = document.specialist_sectors.map(&:tag)

    # These methods are located in gds_api_adapters
    stubbed_artefact = artefact_for_slug_with_a_child_tags('specialist_sector', artefact_slug, tag_slugs)
    content_api_has_an_artefact(artefact_slug, stubbed_artefact)
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

  def create_document_tagged_to_a_specialist_sector
    create(:published_publication, :guidance,
            primary_specialist_sector_tag: 'oil-and-gas/wells',
            secondary_specialist_sector_tags: ['oil-and-gas/offshore', 'oil-and-gas/fields']
    )
  end

  def check_for_primary_sector_in_heading
    assert has_content?("Oil and gas - guidance")
  end

  def check_for_primary_subsector_in_title(document_title)
    assert has_content?("Wells - #{document_title}")
  end

  def check_for_all_sectors_in_metadata
    ['Oil and gas', 'Wells', 'Offshore', 'Fields'].each do |sector_name|
      assert has_css?('.document-sectors', text: sector_name)
    end
  end
end

World(SpecialistSectorHelper)
