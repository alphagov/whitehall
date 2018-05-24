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
  publishing_api_has_linkables([], document_type: 'topic')
end

module SpecialistSectorHelper
  include GdsApi::TestHelpers::ContentStore

  def stub_specialist_sectors
    publishing_api_has_linkables(
      [
        {
          'content_id' => 'WELLS',
          'internal_name' => 'Oil and Gas / Wells',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'FIELDS',
          'internal_name' => 'Oil and Gas / Fields',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'OFFSHORE',
          'internal_name' => 'Oil and Gas / Offshore',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'DISTILL',
          'internal_name' => 'Oil and Gas / Distillation',
          'publication_state' => 'draft',
        },
      ],
      document_type: 'topic'
    )
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
    click_on "Next"
    assert_equal 'WELLS', find_field('Primary specialist sector').value
    assert_equal %w[OFFSHORE FIELDS DISTILL].to_set,
                 find_field('Additional specialist sectors').value.to_set
  end

  def save_document
    click_button 'Save'
  end
end

World(SpecialistSectorHelper)
