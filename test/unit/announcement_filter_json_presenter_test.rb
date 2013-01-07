require 'test_helper'

class AnnouncementFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = stub_everything("Whitehall::DocumentFilter",
      count: 1,
      current_page: 1,
      num_pages: 1,
      documents: [])
    self.params[:action] = :index
    self.params[:controller] = :announcements
  end

  test "adds field of operations to the document_hash if exists" do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Defence", organisation_type: stub_record(:organisation_type))
    operational_field = stub_record(:operational_field, name: "Name")
    fatality_notice = stub_record(:fatality_notice,
      document: document,
      first_published_at: Time.zone.now,
      organisations: [organisation],
      operational_field: operational_field)
    # TODO: perhaps rethink edition factory, so this apparent duplication 
    # isn't neccessary
    fatality_notice.stubs(:organisations).returns([organisation])
    hash = AnnouncementFilterJsonPresenter.new(@filter).document_hash(AnnouncementPresenter.new(fatality_notice))
    assert hash[:field_of_operation]
  end
end
