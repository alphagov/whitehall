require "test_helper"

class SpecialistGuidesControllerTest < ActionController::TestCase
  include SpecialistGuideViewAssertions

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
    assert_select_specialist_guide_section_link guide, 'First Section', 'first-section'
    assert_select_specialist_guide_section_link guide, 'Another Bit', 'another-bit'
    assert_select_specialist_guide_section_link guide, 'Final Part', 'final-part'
  end
end
