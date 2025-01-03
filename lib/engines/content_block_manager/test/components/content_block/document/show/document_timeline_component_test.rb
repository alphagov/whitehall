require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  test "renders a timeline component with events in correct order" do
    @user = create(:user)
    @version_1 = create(
      :content_block_version,
      event: "created",
      whodunnit: @user.id,
    )
    @version_2 = create(
      :content_block_version,
      event: "updated",
      whodunnit: @user.id,
      state: "published",
    )
    @version_3 = create(
      :content_block_version,
      event: "updated",
      whodunnit: @user.id,
      state: "scheduled",
    )

    render_inline(ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
                    content_block_versions: [@version_3, @version_2, @version_1],
                  ))

    assert_selector ".timeline__item", count: 2

    assert_equal "Email address scheduled", page.all(".timeline__title")[0].text
    assert_equal "by #{linked_author(@user, { class: 'govuk-link' })}", page.all(".timeline__byline")[0].native.inner_html
    assert_equal  I18n.l(@version_3.created_at, format: :long_ordinal),
                  page.all("time[datetime='#{@version_3.created_at.iso8601}']")[1].text

    assert_equal "Email address published", page.all(".timeline__title")[1].text
    assert_equal "by #{linked_author(@user, { class: 'govuk-link' })}", page.all(".timeline__byline")[1].native.inner_html
    assert_equal  I18n.l(@version_2.created_at, format: :long_ordinal),
                  page.all("time[datetime='#{@version_2.created_at.iso8601}']")[1].text
  end
end
