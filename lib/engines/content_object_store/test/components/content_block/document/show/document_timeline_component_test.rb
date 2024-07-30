require "test_helper"

class ContentObjectStore::ContentBlock::Document::Show::DocumentTimelineComponentTest < ViewComponent::TestCase
  test "renders a timeline component with events in correct order" do
    @user = create(:user)
    @content_block_edition_1 = create(
      :content_block_edition,
      document: create(
        :content_block_document,
        block_type: "email_address",
      ),
    )
    @content_block_version_1 = create(
      :content_block_version,
      item: @content_block_edition_1,
      whodunnit: @user.id,
    )
    @content_block_edition_2 = create(
      :content_block_edition,
      document: create(
        :content_block_document,
        block_type: "email_address",
      ),
    )
    @content_block_version_2 = create(
      :content_block_version,
      item: @content_block_edition_2,
      whodunnit: @user.id,
    )

    render_inline(ContentObjectStore::ContentBlock::Document::Show::DocumentTimelineComponent.new(
                    content_block_versions: [@content_block_version_1, @content_block_version_2],
                  ))

    assert_selector ".timeline__item", count: 2
    assert_equal page.all(".timeline__title")[0].text, "Email address changed"
    assert_equal page.all(".timeline__byline")[0].text, "by #{@user.name}"
    assert_equal page.all("time[datetime='#{@content_block_version_2.created_at.iso8601}']")[0].text,
                 @content_block_version_2.created_at.strftime("%d %B %Y at %I:%M%P")

    assert_equal page.all(".timeline__title")[1].text, "Email address created"
    assert_equal page.all(".timeline__byline")[1].text, "by #{@user.name}"
    assert_equal page.all("time[datetime='#{@content_block_version_2.created_at.iso8601}']")[1].text,
                 @content_block_version_2.created_at.strftime("%d %B %Y at %I:%M%P")
  end
end
