require "test_helper"
require "gds_api/panopticon"
require "gds_api/test_helpers/panopticon"
require "gds_api/test_helpers/publishing_api"

class UnpublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Panopticon
  include GdsApi::TestHelpers::PublishingApi

  setup do
    @published_edition = create(:published_case_study)
    @registerable = RegisterableEdition.new(@published_edition)
    @request = stub_artefact_registration(@registerable.slug)
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

  test "When unpublishing an edition, its state is updated in Panopticon" do
    unpublish(@published_edition, unpublishing_params)

    assert_requested @request
    assert_equal "archived", @registerable.state
  end

  test 'When a case study is unpublished, an "unpublishing" is published to the Publishing API' do
    path = Whitehall.url_maker.public_document_path(@published_edition)
    stub_panopticon_registration(@published_edition)
    unpublish(@published_edition, unpublishing_params)
    assert_publishing_api_put_item(path, format: 'unpublishing')
  end

  test 'When a case study is unpublished, a job is queued to republish the draft to the draft stack' do
    path = Whitehall.url_maker.public_document_path(@published_edition)
    stub_panopticon_registration(@published_edition)

    Whitehall::PublishingApi.expects(:publish_draft_async).once

    unpublish(@published_edition, unpublishing_params)
  end

  test 'When an edition that is not a case study is unpublished, no "unpublishing" is sent to the Publishing API' do
    detailed_guide = create(:published_detailed_guide)
    path = Whitehall.url_maker.public_document_path(detailed_guide)
    stub_panopticon_registration(detailed_guide)
    unpublish(detailed_guide, unpublishing_params)
    assert_not_requested(:put, %r{#{PUBLISHING_API_ENDPOINT}/content.*})
  end

  test 'when a translated edition is unpublished, an "unpublishing" is published to the Publishing API for each translation' do
    en_path = Whitehall.url_maker.public_document_path(@published_edition)
    fr_path = Whitehall.url_maker.public_document_path(@published_edition, locale: 'fr')

    I18n.with_locale 'fr' do
      @published_edition.title = "French title"
      @published_edition.body = "French body"
      @published_edition.save!(validate: false)
    end

    unpublish(@published_edition, unpublishing_params)

    assert_publishing_api_put_item(en_path, format: 'unpublishing')
    assert_publishing_api_put_item(fr_path, format: 'unpublishing')
  end

  test 'when a translated edition is unpublished as a redirect, redirects are published to the Publishing API for each translation' do
    en_path = Whitehall.url_maker.public_document_path(@published_edition)
    fr_path = Whitehall.url_maker.public_document_path(@published_edition, locale: 'fr')

    I18n.with_locale 'fr' do
      @published_edition.title = "French title"
      @published_edition.body = "French body"
      @published_edition.save!(validate: false)
    end

    unpublishing_redirect_params = unpublishing_params.merge({
      redirect: true,
      alternative_url: (Whitehall.public_root + '/government/page')
    })

    unpublish(@published_edition, unpublishing_redirect_params)

    assert_publishing_api_put_item(en_path, format: 'redirect')
    assert_publishing_api_put_item(fr_path, format: 'redirect')
  end

private
  def unpublish(edition, params)
    Whitehall.edition_services.unpublisher(edition, unpublishing: params).perform!
  end

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PublishedInError.id, explanation: "Published by mistake" }
  end
end
