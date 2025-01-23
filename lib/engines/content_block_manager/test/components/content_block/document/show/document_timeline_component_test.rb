require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  test "renders a timeline component with events in correct order" do
    changed_fields = [ContentBlockManager::ContentBlock::Version::ChangedField.new(
      field_name: "email_address",
      new: "new@email.com",
      previous: "old@email.com",
    )]
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
      changed_fields:,
    )

    render_inline(ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
                    content_block_versions: [@version_3, @version_2, @version_1],
                  ))

    assert_selector ".timeline__item", count: 2

    assert_equal "Email address scheduled", page.all(".timeline__title")[0].text
    assert_equal "by #{linked_author(@user, { class: 'govuk-link' })}", page.all(".timeline__byline")[0].native.inner_html
    assert_equal  I18n.l(@version_3.created_at, format: :long_ordinal),
                  page.all("time[datetime='#{@version_3.created_at.iso8601}']")[1].text
    assert_equal "old@email.com", page.all("td")[0].text
    assert_equal "new@email.com", page.all("td")[1].text

    assert_equal "Email address published", page.all(".timeline__title")[1].text
    assert_equal "by #{linked_author(@user, { class: 'govuk-link' })}", page.all(".timeline__byline")[1].native.inner_html
    assert_equal  I18n.l(@version_2.created_at, format: :long_ordinal),
                  page.all("time[datetime='#{@version_2.created_at.iso8601}']")[1].text
  end

    test "renders the changed fields in correct order" do
      changed_fields = [
        ContentBlockManager::ContentBlock::Version::ChangedField.new(
          field_name: "email_address",
          new: "new@email.com",
          previous: "old@email.com",
          ),
        ContentBlockManager::ContentBlock::Version::ChangedField.new(
          field_name: "another_details_field",
          new: "new field",
          previous: "old field",
          ),
        ContentBlockManager::ContentBlock::Version::ChangedField.new(
          field_name: "lead_organisation",
          new: "new org",
          previous: "old org",
          ),
        ContentBlockManager::ContentBlock::Version::ChangedField.new(
          field_name: "instructions_to_publishers",
          new: "new instructions",
          previous: "old instructions",
          ),
        ContentBlockManager::ContentBlock::Version::ChangedField.new(
          field_name: "title",
          new: "new title",
          previous: "old title",
          ),
      ]
      @user = create(:user)
      @version = create(
        :content_block_version,
        event: "updated",
        whodunnit: @user.id,
        state: "scheduled",
        changed_fields:,
        )

      render_inline(ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
        content_block_versions: [@version],
        ))

      assert_equal "old title", page.all("td")[0].text
      assert_equal "new title", page.all("td")[1].text
      # assert_equal "new@email.com", page.all("td")[2].text
      # assert_equal "old@email.com", page.all("td")[3].text
      # # assert_equal "new details", page.all("td")[4].text
      # assert_equal "old details", page.all("td")[5].text
      # assert_equal "old org", page.all("td")[6].text
      # assert_equal "new org", page.all("td")[7].text
      # # assert_equal "old instructions", page.all("td")[8].text
      # assert_equal "new instructions", page.all("td")[9].text
    end
end
