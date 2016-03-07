require 'test_helper'
require 'gds_api/test_helpers/panopticon'

class EditionUnwithdrawerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Panopticon

  def stub_live_artefact_registration(edition)
    # We use RegisterableEdition to ensure we get the same slug mangling
    registerable = RegisterableEdition.new(edition)
    stub_artefact_registration(registerable.slug, hash_including(state: "live"), true)
  end

  setup do
    @edition = FactoryGirl.create(:published_edition, state: 'withdrawn')
    @user = FactoryGirl.create(:user)
    @panopticon_request = stub_live_artefact_registration(@edition)
    stub_any_publishing_api_call
  end

  test "initialize raises an error unless the edition is withdrawn" do
    @edition.update_attribute(:state, "published")
    unwithdraw

    assert_equal ["An edition that is published cannot be unwithdrawn"], @unwithdrawer.failure_reasons
  end

  test "unwithdraw performs steps in a transaction" do
    EditionForcePublisher.any_instance.stubs(:perform!).raises("Something bad happened here.")

    assert_raises RuntimeError do
      unwithdraw
    end
    @edition.reload

    assert_equal "withdrawn", @edition.state
  end

  test "unwithdraw updates the state of the original edition to superseded" do
    unwithdraw
    @edition.reload
    assert_equal "superseded", @edition.state
  end

  test "unwithdraw publishes a draft of the withdrawn edition" do
    unwithdrawn_edition = unwithdraw
    assert unwithdrawn_edition.published?
    assert unwithdrawn_edition.minor_change
    assert_equal @edition.document, unwithdrawn_edition.document
    assert_equal @user, unwithdrawn_edition.editorial_remarks.first.author
    assert_equal "Unwithdrawn", unwithdrawn_edition.editorial_remarks.first.body
  end

  test "unwithdraw handles legacy withdrawn editions" do
    edition = FactoryGirl.create(:published_edition, state: 'withdrawn')
    stub_live_artefact_registration(edition)

    unwithdrawn_edition = unwithdraw(edition)

    assert unwithdrawn_edition.published?
    assert unwithdrawn_edition.minor_change
    assert_equal edition.document, unwithdrawn_edition.document
    assert_equal @user, unwithdrawn_edition.editorial_remarks.first.author
    assert_equal "Unwithdrawn", unwithdrawn_edition.editorial_remarks.first.body
  end

  test "unwithdraw handles re-registration with Panopticon" do
    unwithdraw

    assert_requested @panopticon_request
  end

  def unwithdraw(edition = nil)
    edition ||= @edition
    @unwithdrawer = EditionUnwithdrawer.new(edition, user: @user)
    @unwithdrawer.perform!
    edition.document.published_edition
  end
end
