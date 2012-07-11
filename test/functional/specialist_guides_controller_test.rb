require "test_helper"

class SpecialistGuidesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller
  should_display_attachments_for :specialist_guide

  test "index <title> does not contain 'Inside Government'" do
    get :index

    refute_select "title", text: /Inside Government/
  end

  test "guide <title> contains Specialist guidance" do
    guide = create(:published_specialist_guide)

    get :show, id: guide.document

    assert_select "title", text: /${guide.document.title} | Specialist guidance/
  end

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

  test "adds pagination behaviour to paginated guide" do
    edition = create(:published_specialist_guide, paginate_body: true)
    get :show, id: edition.document

    assert_select ".document.js-paginate-document"
  end

  test "doesn't add pagination behaviour to non-paginated guide" do
    edition = create(:published_specialist_guide, paginate_body: false)
    get :show, id: edition.document

    assert_select ".document.js-paginate-document", count: 0
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
