require "test_helper"

class UnpublishingTest < ActiveSupport::TestCase
  setup do
    @published_edition = create(:published_case_study)
    stub_any_publishing_api_call
  end

  test "When unpublishing an edition, its state reverts to draft in Whitehall" do
    unpublish(@published_edition, unpublishing_params)

    @published_edition.reload

    assert_equal "draft", @published_edition.state
    refute_nil @published_edition.unpublishing
  end

  test "When unpublishing an edition, it is removed from the search index" do
    Whitehall::SearchIndex.expects(:delete).with(@published_edition)

    unpublish(@published_edition, unpublishing_params)
  end

  test "When an edition is unpublished, it is unpublished to the Publishing API" do
    unpublish(@published_edition, unpublishing_params)

    assert_publishing_api_unpublish(
      @published_edition.document.content_id,
      request_json_includes(type: "gone", explanation: "<div class=\"govspeak\"><p>Published by mistake</p>\n</div>", locale: "en")
    )
  end

  test "When an edition is unpublished, a job is queued to republish the draft to the draft stack" do
    Whitehall::PublishingApi.expects(:save_draft_async).once

    unpublish(@published_edition, unpublishing_params)
  end

  test "when a translated edition is unpublished, an request is made for each locale" do
    I18n.with_locale 'fr' do
      @published_edition.title = "French title"
      @published_edition.body = "French body"
      @published_edition.save!(validate: false)
    end

    unpublish(@published_edition, unpublishing_params)

    %w(en fr).each do |locale|
      assert_publishing_api_unpublish(
        @published_edition.document.content_id,
        {
          type: "gone",
          explanation: "<div class=\"govspeak\"><p>Published by mistake</p>\n</div>",
          locale: locale,
          discard_drafts: true,
        }
      )
    end
  end

  test "when a translated edition is unpublished with a redirect, redirects are sent to the Publishing API for each translation" do
    redirect_uuid = SecureRandom.uuid
    SecureRandom.stubs(uuid: redirect_uuid)

    I18n.with_locale 'fr' do
      @published_edition.title = "French title"
      @published_edition.body = "French body"
      @published_edition.save!(validate: false)
    end

    unpublishing_redirect_params = unpublishing_params.merge({
      redirect: true,
      alternative_url: Whitehall.public_root + '/government/page',
    })

    unpublish(@published_edition, unpublishing_redirect_params)

    %w(en fr).each do |locale|
      assert_publishing_api_unpublish(
        @published_edition.document.content_id,
        {
          type: "redirect",
          alternative_path: "/government/page",
          locale: locale,
          discard_drafts: true
        }
      )
    end
  end

private

  def unpublish(edition, params)
    Whitehall.edition_services.unpublisher(edition, unpublishing: params).perform!
  end

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PUBLISHED_IN_ERROR_ID, explanation: "Published by mistake" }
  end
end
