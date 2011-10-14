require "test_helper"

class PublicationTest < ActiveSupport::TestCase

  test "should build a draft copy of the existing publication" do
    attachment = create(:attachment)
    published_publication = create(:published_publication, attachment: attachment)

    draft_publication = published_publication.build_draft(create(:policy_writer))

    assert_equal published_publication.attachment, draft_publication.attachment
  end

  test "allows attachment" do
    assert build(:publication).allows_attachment?
  end
end