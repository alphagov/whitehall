require "test_helper"
require "gds_api/test_helpers/content_store"

class SpecialistTagFinderTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  setup do
    @edition = stub
    @tag_finder = SpecialistTagFinder.new(@edition)

    @parent_tag = stub(details: {'type' => 'specialist_sector'}, slug: 'super')
    @primary_tag = stub(details: {'type' => 'specialist_sector'},
                        slug: 'super/primary', parent: @parent_tag)
    @secondary_tag = stub(details: {'type' => 'specialist_sector'},
                          slug: 'super/secondary', parent: @parent_tag)
    @irrelevant_tag = stub(details: {'type' => 'something_else'})

    @artefact = stub(tags: [
      @primary_tag,
      @secondary_tag,
      @irrelevant_tag
    ])

    @tag_finder.stubs(artefact: @artefact)
  end

  test "#topics returns all linked topics" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApiPresenters::Edition.new(edition).base_path
    content_item = content_item_for_base_path(edition_base_path).merge!({
      "links" => {
        "topics" => [
          { "title" => "topic-1" },
          { "title" => "topic-2" },
        ]
      }
    })

    content_store_has_item(edition_base_path, content_item)

    assert_equal ["topic-1", "topic-2"], SpecialistTagFinder.new(edition).topics.map { |topic| topic["title"] }
  end

  test "#primary_sector_tag returns the primary subsector tag's parent" do
    subsector_tag = mock(parent: 'parent_tag')
    @tag_finder.stubs(primary_subsector_tag: subsector_tag)

    assert_equal 'parent_tag', @tag_finder.primary_sector_tag
  end

  test "#primary_sector_tag returns nil if no primary subsector tag" do
    @tag_finder.stubs(primary_subsector_tag: nil)

    assert_equal nil, @tag_finder.primary_sector_tag
  end

  test "#primary_subsector_tag returns the specialist sector tag whose slug matches the primary" do
    @edition.stubs(primary_specialist_sector_tag: 'super/primary')

    assert_equal @primary_tag, @tag_finder.primary_subsector_tag
  end

  test "#primary_subsector_tag returns nil if no primary specialist sector tag" do
    @edition.stubs(primary_specialist_sector_tag: nil)

    assert_equal nil, @tag_finder.primary_subsector_tag
  end

  test "#sectors_and_subsectors returns all relevant tags and parent tags" do
    assert_equal [@parent_tag, @primary_tag, @secondary_tag].to_set,
                 @tag_finder.sectors_and_subsectors.to_set
  end
end
