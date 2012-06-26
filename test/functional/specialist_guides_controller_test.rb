require "test_helper"

class SpecialistGuidesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller
  should_display_attachments_for :specialist_guide

  test "shows link to each section in the markdown" do
    guide = create(:published_specialist_guide, body: %{
## First Section

Some content

## Another Bit

More content

## Final Part

That's all
})

    get :show, id: guide.document

    assert_select_document_section_link guide, 'First Section', 'first-section'
    assert_select_document_section_link guide, 'Another Bit', 'another-bit'
    assert_select_document_section_link guide, 'Final Part', 'final-part'
  end
end
