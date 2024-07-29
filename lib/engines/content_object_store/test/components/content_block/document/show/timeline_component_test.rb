require "test_helper"

class ContentObjectStore::ContentBlock::Document::Show::TimelineComponentTest < ViewComponent::TestCase
  test "renders a timeline component with a created event" do
    @user = create(:user)
    @content_block_edition = create(:content_block_edition, :email_address)
    @content_block_version = create(
      :content_block_version,
      item: @content_block_edition,
      whodunnit: @user.id,
    )

    render_inline(ContentObjectStore::ContentBlock::Document::Show::TimelineComponent.new(
                    content_block_versions: [@content_block_version],
                  ))

    assert_selector ".timeline__item", count: 1
    assert_selector ".timeline__title", text: "Email address created"
    assert_selector ".timeline__byline", text: "by #{@user.name}"
    assert_selector "time[datetime='#{@content_block_version.created_at.iso8601}']",
                    text: @content_block_version.created_at.strftime("%d %B %Y at %I:%M%P")
  end
end
