require "test_helper"

class CaseStudyDetailsSerializerTest < ActiveSupport::TestCase
  def org1
    stub(content_id: 1)
  end

  def org2
    stub(content_id: 2)
  end

  def stubbed_item
    @stubbed_item ||= stub(
      change_history: { "change" => "first_change" },
      lead_organisations: [org1, org2],
      display_type_key: 'a display type format'
    )
  end

  def serializer
    CaseStudyDetailsSerializer.new(stubbed_item)
  end

  test 'it includes a body' do
    govspeak_instance_mock = MiniTest::Mock.new
    govspeak_instance_mock.expect(
      :govspeak_edition_to_html,
      "<div>edition in html</div>",
      [stubbed_item]
    )

    Whitehall::GovspeakRenderer.stub(:new, govspeak_instance_mock) do
      assert_equal serializer.body, "<div>edition in html</div>"
    end
    govspeak_instance_mock.verify
  end

  test 'it includes the change history' do
    assert_equal serializer.change_history, stubbed_item.change_history
  end

  test 'it includes emphasised organisations' do
    assert_equal(serializer.emphasised_organisations, [1, 2])
  end

  test 'it includes the first public at date when the document was published' do
    stubbed_item = stub(
      document: stub(published?: true),
      first_public_at: 'a date'
    )
    serializer = CaseStudyDetailsSerializer.new(stubbed_item)

    assert_equal serializer.first_public_at, stubbed_item.first_public_at
  end

  test 'it includes the first public at date as the created at date when the document was not published' do
    stubbed_document = stub(
      created_at: Date.today,
      published?: false
    )
    stubbed_item = stub(document: stubbed_document)
    serializer = CaseStudyDetailsSerializer.new(stubbed_item)

    assert_equal serializer.first_public_at, stubbed_document.created_at.iso8601
  end

  test 'it includes the format display type' do
    assert_equal serializer.format_display_type, stubbed_item.display_type_key
  end

  test 'it includes tag attributes' do
    tags = { tag1: :tag1, tag2: :tag2 }
    tag_details_mock = MiniTest::Mock.new
    tag_details_mock.expect(:as_json, tags)

    TagDetailsSerializer.stub(:new, tag_details_mock) do
      assert_equal serializer.tag, tags
    end
    tag_details_mock.verify
  end

  test 'it includes an image attribute when there are images' do
    image_hash = { url: 'a url' }
    image_details_mock = MiniTest::Mock.new
    image_details_mock.expect(:as_json, image_hash)

    ImageDetailsSerializer.stub(:new, image_details_mock) do
      assert_equal serializer.image, image_hash
    end
    image_details_mock.verify
  end
end
