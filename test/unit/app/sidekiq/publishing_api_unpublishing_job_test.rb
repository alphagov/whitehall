require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApiUnpublishingJobTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  # UnpublishingReason: 1 - in error
  test "runs PublishingApiGoneJob with path and explanation when redirect is false" do
    unpublished_edition = create(
      :unpublished_edition,
      :published_in_error_no_redirect,
    )

    PublishingApiGoneJob.expects(:new).returns(gone_job = mock)
    unpublishing = unpublished_edition.unpublishing

    gone_job.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.alternative_path,
      unpublishing.explanation,
      "en",
      false,
    )

    PublishingApiUnpublishingJob.new.perform(unpublished_edition.unpublishing.id)
  end

  # UnpublishingReason: 1 - in error, redirect: true
  test "runs PublishingApiGoneJob with path when redirect is true" do
    unpublished_edition = create(
      :unpublished_edition,
      :published_in_error_redirect,
    )

    PublishingApiRedirectJob.expects(:new).returns(redirect_job = mock)
    unpublishing = unpublished_edition.unpublishing

    redirect_job.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.alternative_path,
      "en",
      false,
    )

    PublishingApiUnpublishingJob.new.perform(unpublished_edition.unpublishing.id)
  end

  # UnpublishingReason: 4 - consolidated
  test "runs PublishingApiRedirectJob with alternative path" do
    unpublished_edition = create(
      :unpublished_edition,
      :consolidated_redirect,
    )

    PublishingApiRedirectJob.expects(:new).returns(redirect_job = mock)
    unpublishing = unpublished_edition.unpublishing

    redirect_job.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.alternative_path,
      "en",
      false,
    )

    PublishingApiUnpublishingJob.new.perform(unpublished_edition.unpublishing.id)
  end

  # UnpublishingReason: 5 - withdrawn
  test "runs PublishingApiWithdrawalJob with alternative path" do
    unpublished_edition = create(
      :withdrawn_edition,
    )

    PublishingApiWithdrawalJob.expects(:new).returns(withdrawal_job = mock)
    unpublishing = unpublished_edition.unpublishing

    withdrawal_job.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.explanation,
      "en",
      false,
      unpublishing.unpublished_at.to_s,
    )

    PublishingApiUnpublishingJob.new.perform(unpublished_edition.unpublishing.id)
  end

  test "passes allow_draft if supplied" do
    unpublished_edition = create(
      :withdrawn_edition,
    )

    PublishingApiWithdrawalJob.expects(:new).returns(withdrawal_job = mock)
    unpublishing = unpublished_edition.unpublishing

    withdrawal_job.expects(:perform).with(
      unpublished_edition.document.content_id,
      unpublishing.explanation,
      "en",
      true,
      unpublishing.unpublished_at.to_s,
    )

    PublishingApiUnpublishingJob.new.perform(unpublished_edition.unpublishing.id, true)
  end
end
