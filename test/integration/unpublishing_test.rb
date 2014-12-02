require "test_helper"
require "gds_api/panopticon"
require "gds_api/test_helpers/panopticon"
require "gds_api/test_helpers/publishing_api"

class UnpublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Panopticon
  include GdsApi::TestHelpers::PublishingApi

  setup do
    @published_edition = create(:published_edition)
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

  test "When unpublishing an edition, it gets republished to the Publishing API with an unpublish format" do
    path = Whitehall.url_maker.public_document_path(@published_edition)
    stub_panopticon_registration(@published_edition)
    unpublish(@published_edition, unpublishing_params)
    assert_publishing_api_put_item(path, format: 'unpublishing')
  end

private
  def unpublish(edition, params)
    Whitehall.edition_services.unpublisher(edition, unpublishing: params).perform!
  end

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PublishedInError.id, explanation: "Published by mistake" }
  end
end
