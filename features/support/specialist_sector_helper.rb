require 'gds_api/test_helpers/content_api'
require "gds_api/test_helpers/content_store"

Before do
  # FIXME: This stubs out calls to the content store, returning an empty
  # response. Calls to this endpoint are only needed in SpecialistTagFinder,
  # for rendering the header in Whitehall frontend. Ideally this should be
  # replaced by explicit stubs in every feature that renders a frontend page.
  # That's a fairly large reworking of the tests, however, and those pages are
  # in the process of being migrated to government-frontend. For now then, this
  # stub should be overriden in specific features where this behaviour needs to
  # be tested.
  stub_request(:get, %r{.*content-store.*/content/.*}).to_return(status: 404)
end

module SpecialistSectorHelper
  include GdsApi::TestHelpers::ContentApi
  include GdsApi::TestHelpers::ContentStore

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
end

World(SpecialistSectorHelper)
