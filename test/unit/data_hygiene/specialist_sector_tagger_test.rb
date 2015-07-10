require "test_helper"
require "data_hygiene/specialist_sector_tagger"

class SpecialistSectorTaggerTest < ActiveSupport::TestCase
  setup do
    @published_edition = create(:published_edition)
    @document = @published_edition.document
    @draft_edition = create(:draft_edition, document: @document)
    @gds_user = create(:gds_team_user)
    @tag_slug = "transport/transporting-goods"
    stub_registration
  end

  test "adds specialist_sector taggings to all editions of the document" do
    SpecialistSectorTagger.new(@document.document_type, @document.slug,
                               @tag_slug).process

    assert_equal 1, @published_edition.specialist_sectors.size
    assert_equal 1, @draft_edition.specialist_sectors.size
    assert_equal @tag_slug, @published_edition.specialist_sectors.first.tag
    assert_equal @tag_slug, @draft_edition.specialist_sectors.first.tag
  end

  test "does not add duplicate taggings" do
    SpecialistSector.create!(edition_id: @draft_edition.id, tag: @tag_slug)

    SpecialistSectorTagger.new(@document.document_type, @document.slug,
                               @tag_slug).process

    assert_equal 1, @draft_edition.specialist_sectors.size
  end

  test "logs a warning and returns if a document cannot be found" do
    log_output = StringIO.new("")
    assert_nothing_raised do
      SpecialistSectorTagger.new(@document.document_type, "foo", @tag_slug,
                                 logger: Logger.new(log_output)).process
    end

    assert_match /warning/, log_output.string
  end

  test "re-registers the published edition" do
    Whitehall::PublishingApi.expects(:republish_async).with(@published_edition)
    ServiceListeners::SearchIndexer.expects(:new).with(@published_edition)
      .returns(mock(index!: true))
    ServiceListeners::PanopticonRegistrar.expects(:new).with(@published_edition)
      .returns(mock(register!: true))

    SpecialistSectorTagger.new(@document.document_type, @document.slug,
                               @tag_slug).process
  end

  test "registers nothing if there are no published editions" do
    @published_edition.destroy
    Whitehall::PublishingApi.expects(:republish_async).never
    ServiceListeners::SearchIndexer.expects(:new).never
    ServiceListeners::PanopticonRegistrar.expects(:new).never

    SpecialistSectorTagger.new(@document.document_type, @document.slug,
                               @tag_slug).process
  end

  def stub_registration
    Whitehall::PublishingApi.stubs(:republish_async)
    ServiceListeners::SearchIndexer.any_instance.stubs(:index!)
    ServiceListeners::PanopticonRegistrar.any_instance.stubs(:register!)
  end
end
