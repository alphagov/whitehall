require "test_helper"

class SpecialistGuidesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller
  should_display_attachments_for :specialist_guide

  test "shows link to each section in the document navigation" do
    guide = create(:published_specialist_guide, body: %{
## First Section

Some content

## Another Bit

More content

## Final Part

That's all
})

    get :show, id: guide.document

    assert_select "ol#document_sections" do
      assert_select "li a[href='#{public_document_path(guide, anchor: 'first-section')}']", 'First Section'
      assert_select "li a[href='#{public_document_path(guide, anchor: 'another-bit')}']", 'Another Bit'
      assert_select "li a[href='#{public_document_path(guide, anchor: 'final-part')}']", 'Final Part'
    end
  end

  test "should link to topics related to the specialist guide" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    edition = create(:published_specialist_guide, topics: [first_topic, second_topic])

    get :show, id: edition.document

    assert_select "#topics li.topic a", text: first_topic.name
    assert_select "#topics li.topic a", text: second_topic.name
  end

  test "shows link to subsections in the document navigation" do
    guide = create(:published_specialist_guide, body: %{
## First Section

Some Content

### Sub section title

some more content
})

    get :show, id: guide.document

    assert_select "ol#document_sections" do
      assert_select "li ol li a[href='#{public_document_path(guide, anchor: 'sub-section-title')}']", 'Sub section title'
    end
  end

  test "index shows all published specialist guides by topic" do
    earth = create(:topic, name: "Earth")
    wind = create(:topic, name: "Wind")
    guide1 = create(:published_specialist_guide, title: "One", topics: [earth])
    guide2 = create(:published_specialist_guide, title: "Two", topics: [earth, wind])

    get :index

    assert_select_object earth do
      assert_select "h2", text: "Earth"
      assert_select_object guide1
      assert_select_object guide2
    end
    assert_select_object wind do
      assert_select "h2", text: "Wind"
      assert_select_object guide2
    end
  end

  test "index hides topics which have no specialist guides" do
    earth = create(:topic, name: "Earth")
    wind = create(:topic, name: "Wind")
    guide1 = create(:published_specialist_guide, title: "One", topics: [earth])

    get :index

    refute_select_object wind
  end


end
