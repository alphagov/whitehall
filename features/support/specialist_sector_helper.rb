require 'gds_api/test_helpers/content_api'

module SpecialistSectorHelper
  include GdsApi::TestHelpers::ContentApi

  def stub_specialist_sectors
    oil_and_gas = { slug: 'oil-and-gas', title: 'Oil and Gas' }
    sector_tags = [
      oil_and_gas,
      { slug: 'oil-and-gas/wells', title: 'Wells', parent: oil_and_gas },
      { slug: 'oil-and-gas/fields', title: 'Fields', parent: oil_and_gas },
      { slug: 'oil-and-gas/offshore', title: 'Offshore', parent: oil_and_gas }
    ]

    distillation = { slug: 'oil-and-gas/distillation', title: 'Distillation', parent: oil_and_gas }

    content_api_has_draft_and_live_tags(type: 'specialist_sector', live: sector_tags, draft: [distillation])
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
    select 'Oil and Gas: Distillation (draft)', from: 'Additional specialist sectors'
  end

  def assert_specialist_sectors_were_saved
    assert has_css?('.flash.notice')
    click_on 'Edit draft'
    assert_equal 'oil-and-gas/wells', find_field('Primary specialist sector').value
    assert_equal ['oil-and-gas/offshore', 'oil-and-gas/fields', 'oil-and-gas/distillation'].to_set,
                 find_field('Additional specialist sectors').value.to_set
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
    assert find("article header").has_content?("Oil and gas")
  end

  def check_for_sectors_and_subsectors_in_metadata
    ['Oil and gas', 'Wells', 'Offshore', 'Fields'].each do |sector_name|
      assert has_css?('dd', text: sector_name, exact: false)
    end
  end

  def check_for_absence_of_draft_sectors_and_subsectors_in_metadata
    assert has_no_css?('dd', text: 'Distillation', exact: false)
  end
end

World(SpecialistSectorHelper)
