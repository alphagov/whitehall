require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiUnpublishingWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  # UnpublishingReason: 1 - in error
  test "runs PublishingApiGoneWorker with path and explanation when redirect is false" do
    unpublished_edition = create(
      :unpublished_edition,
      :published_in_error_no_redirect,
    )

    PublishingApiGoneWorker.expects(:new).returns(gone_worker = mock)
    unpublishing = unpublished_edition.unpublishing

    gone_worker.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.alternative_path,
      unpublishing.explanation,
      :en,
      false,
    )

    PublishingApiUnpublishingWorker.new.perform(unpublished_edition.unpublishing.id)
  end

  # UnpublishingReason: 1 - in error, redirect: true
  test "runs PublishingApiGoneWorker with path when redirect is true" do
    unpublished_edition = create(
      :unpublished_edition,
      :published_in_error_redirect,
    )

    PublishingApiRedirectWorker.expects(:new).returns(redirect_worker = mock)
    unpublishing = unpublished_edition.unpublishing

    redirect_worker.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.alternative_path,
      :en,
      false,
    )

    PublishingApiUnpublishingWorker.new.perform(unpublished_edition.unpublishing.id)
  end

  # UnpublishingReason: 4 - consolidated
  test "runs PublishingApiRedirectWorker with alternative path" do
    unpublished_edition = create(
      :unpublished_edition,
      :consolidated_redirect,
    )

    PublishingApiRedirectWorker.expects(:new).returns(redirect_worker = mock)
    unpublishing = unpublished_edition.unpublishing

    redirect_worker.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.alternative_path,
      :en,
      false,
    )

    PublishingApiUnpublishingWorker.new.perform(unpublished_edition.unpublishing.id)
  end

  # UnpublishingReason: 5 - withdrawn
  test "runs PublishingApiWithdrawalWorker with alternative path" do
    unpublished_edition = create(
      :withdrawn_edition,
    )

    PublishingApiWithdrawalWorker.expects(:new).returns(withdrawal_worker = mock)
    unpublishing = unpublished_edition.unpublishing

    withdrawal_worker.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.explanation,
      :en,
      false,
      unpublishing.unpublished_at,
    )

    PublishingApiUnpublishingWorker.new.perform(unpublished_edition.unpublishing.id)
  end

  test "resends a draft to the publishing api" do
    unpublished_edition = create(
      :unpublished_edition,
      :consolidated_redirect,
    )

    Whitehall::PublishingApi.expects(:save_draft).with(unpublished_edition)
    PublishingApiUnpublishingWorker.new.perform(unpublished_edition.unpublishing.id)
  end

  test "doesn't resend draft to the publishing api if unpublishing reason was withdrawn" do
    unpublished_edition = create(
      :withdrawn_edition,
    )

    Whitehall::PublishingApi.expects(:save_draft).with(unpublished_edition).never
    PublishingApiUnpublishingWorker.new.perform(unpublished_edition.unpublishing.id)
  end

  test "passes allow_draft if supplied" do
    unpublished_edition = create(
      :withdrawn_edition,
    )

    PublishingApiWithdrawalWorker.expects(:new).returns(withdrawal_worker = mock)
    unpublishing = unpublished_edition.unpublishing

    withdrawal_worker.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.explanation,
      :en,
      true,
      unpublishing.unpublished_at,
    )

    PublishingApiUnpublishingWorker.new.perform(unpublished_edition.unpublishing.id, true)
  end
end
