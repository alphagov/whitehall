require "test_helper"
require 'gds_api/panopticon'
require 'gds_api/test_helpers/panopticon'

class UnpublishingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Panopticon

  test "When unpublishing an edition, its state reverts to draft in Whitehall" do
    published_policy = create(:published_policy)
    published_policy.unpublishing = create(:unpublishing)
    stub_artefact_registration(RegisterableEdition.new(published_policy).slug)

    Whitehall.edition_services.unpublisher(published_policy).perform!

    published_policy.reload
    assert_equal 'draft', published_policy.state
    refute_nil published_policy.unpublishing
  end

  test "When unpublishing an edition, it is removed from the search index" do
    published_policy = create(:published_policy)
    published_policy.unpublishing = build(:unpublishing)
    registerable = RegisterableEdition.new(published_policy)
    stub_artefact_registration(registerable.slug)

    Whitehall::SearchIndex.expects(:delete).with(published_policy)
    Whitehall.edition_services.unpublisher(published_policy).perform!

  end

  test "When unpublishing an edition, its state is updated in Panopticon" do
    published_policy = create(:published_policy)
    published_policy.unpublishing = create(:unpublishing)

    registerable = RegisterableEdition.new(published_policy)
    request = stub_artefact_registration(registerable.slug)

    Whitehall.edition_services.unpublisher(published_policy).perform!

    assert_requested request
    assert_equal 'archived', registerable.state
  end
end
