require "test_helper"

class Edition::WorldwideOfficesTest < ActiveSupport::TestCase

  test "can be associated with worldwide offices" do
    assert InternationalPriority.new.can_be_associated_with_worldwide_offices?
  end

  test "#destroy removes association with offices" do
    office = create(:worldwide_office)
    edition = create(:draft_international_priority, worldwide_offices: [office])
    edition.destroy
    refute edition.edition_worldwide_offices.any?
    assert WorldwideOffice.exists?(office)
  end

  test "new editions carry over worldwide offices" do
    office = create(:worldwide_office)
    priority = create(:published_international_priority, worldwide_offices: [office])
    editor = create(:departmental_editor)
    new_edition = priority.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(editor, force: true)

    assert_equal [office], new_edition.worldwide_offices
  end
end
