require "test_helper"
require "gds_api/panopticon"
require "gds_api/test_helpers/panopticon"

class UnpublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Panopticon

  setup do
    @published_edition = create(:published_case_study)
    @registerable = RegisterableEdition.new(@published_edition)
    @request = stub_artefact_registration(@registerable.slug)
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

  test "When unpublishing an edition, its state is updated in Panopticon as 'archived'" do
    unpublish(@published_edition, unpublishing_params)

    assert_requested @request
    assert_equal "archived", @registerable.state
  end

  test "When an edition is unpublished, it is unpublished to the Publishing API" do
    stub_panopticon_registration(@published_edition)
    unpublish(@published_edition, unpublishing_params)

    assert_publishing_api_unpublish(
      @published_edition.document.content_id,
      request_json_includes(type: "gone", explanation: "<div class=\"govspeak\"><p>Published by mistake</p>\n</div>", locale: "en")
    )
  end

  test "When an edition is unpublished, a job is queued to republish the draft to the draft stack" do
    stub_panopticon_registration(@published_edition)

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

    assert_publishing_api_unpublish(@published_edition.document.content_id,
                                    { type: "gone", explanation: "<div class=\"govspeak\"><p>Published by mistake</p>\n</div>", locale: "en"})
    assert_publishing_api_unpublish(@published_edition.document.content_id,
                                    { type: "gone", explanation: "<div class=\"govspeak\"><p>Published by mistake</p>\n</div>", locale: "fr"})
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
      alternative_url: Whitehall.public_root + '/government/page'
    })

    unpublish(@published_edition, unpublishing_redirect_params)

    assert_publishing_api_unpublish(@published_edition.document.content_id,
                                  { type: "redirect", alternative_path: "/government/page", locale: "en"})
    assert_publishing_api_unpublish(@published_edition.document.content_id,
                                  { type: "redirect", alternative_path: "/government/page", locale: "fr"})
  end

private
  def unpublish(edition, params)
    Whitehall.edition_services.unpublisher(edition, unpublishing: params).perform!
  end

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PUBLISHED_IN_ERROR_ID, explanation: "Published by mistake" }
  end
end
