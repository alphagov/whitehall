require "test_helper"

class EditionWithdrawerTest < ActiveSupport::TestCase
  test '#perform! with a published edition that has a valid Unpublishing transitions the edition to an "withdrawn" state' do
    edition = create(:published_edition)
    edition.build_unpublishing(explanation: "Old policy", unpublishing_reason_id: UnpublishingReason::Withdrawn.id)
    unpublisher = EditionWithdrawer.new(edition)

    assert unpublisher.perform!
    assert_equal :withdrawn, edition.reload.current_state
    assert_equal "Old policy", edition.unpublishing.explanation
    assert_equal UnpublishingReason::Withdrawn, edition.unpublishing.unpublishing_reason
    assert_equal "1.0", edition.published_version
  end

  test '"published" editions can be withdrawn' do
    edition = create(:published_edition)
    edition.build_unpublishing(unpublishing_params)
    unpublisher = EditionWithdrawer.new(edition)

    assert unpublisher.perform!
  end

  test '"withdrawn" editions can be withdrawn' do
    edition = create(:withdrawn_edition)
    edition.build_unpublishing(unpublishing_params)
    unpublisher = EditionWithdrawer.new(edition)

    assert unpublisher.perform!
  end

  test "other states cannot be withdrawn" do
    (Edition.available_states - %i[published withdrawn]).each do |state|
      edition = create(:edition, state: state, first_published_at: 1.year.ago)
      edition.build_unpublishing(unpublishing_params)
      unpublisher = EditionWithdrawer.new(edition)

      assert_not unpublisher.perform!
      assert_equal state, edition.current_state
      assert_equal "An edition that is #{state} cannot be withdrawn", unpublisher.failure_reason
    end
  end

  test "even invalid editions can be withdrawn" do
    edition = create(:published_edition)
    edition.build_unpublishing(unpublishing_params)
    edition.summary = nil
    unpublisher = EditionWithdrawer.new(edition)

    assert unpublisher.can_perform?
    assert unpublisher.perform!
    assert edition.reload.withdrawn?
  end

  test "adds user to authors if passed" do
    edition = create(:published_edition)
    edition.build_unpublishing(unpublishing_params)
    user = create(:user)

    unpublisher = EditionWithdrawer.new(edition, user: user)
    unpublisher.perform!
    assert_includes edition.authors, user
  end

  test "cannot withdraw a published editions if a newer draft exists" do
    edition = create(:published_edition)
    edition.create_draft(create(:writer))
    unpublisher = EditionWithdrawer.new(edition)

    assert_not unpublisher.can_perform?
    assert_equal "There is already a draft edition of this document. You must discard it before you can withdraw this edition.",
                 unpublisher.failure_reason
  end

  test "cannot withdraw without an Unpublishing prepared on the edition" do
    edition = create(:published_edition)
    unpublisher = EditionWithdrawer.new(edition)

    assert_not unpublisher.can_perform?
    assert_equal "The reason for unpublishing must be present", unpublisher.failure_reason
  end

  test "cannot withdraw an edition if the Unpublishing is not valid" do
    edition = create(:published_edition)
    edition.build_unpublishing(unpublishing_params.merge(redirect: true))

    unpublisher = EditionWithdrawer.new(edition)

    assert_not unpublisher.can_perform?
    assert_equal "Alternative url must be provided to redirect the document", unpublisher.failure_reason
  end

  test "copies the date & explanation from a previous withdrawal if one is given" do
    document = create(:document)

    previous_edition = create(:withdrawn_edition, document: document).tap do |e|
      e.unpublishing.update!(
        explanation: "Some reason for withdrawing",
        unpublished_at: 1.week.ago,
      )
    end

    edition = create(:published_edition, document: document)

    unpublisher = EditionWithdrawer.new(edition,
                                        previous_withdrawal: previous_edition.unpublishing,
                                        unpublishing: { unpublishing_reason_id: UnpublishingReason::Withdrawn.id })

    assert unpublisher.perform!
    assert_equal :withdrawn, edition.reload.current_state
    assert_equal previous_edition.unpublishing.explanation, edition.unpublishing.explanation
    assert_equal previous_edition.unpublishing.unpublished_at, edition.unpublishing.unpublished_at
    assert_not_equal previous_edition.unpublishing, edition.unpublishing
  end

private

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::Withdrawn.id, explanation: "Old policy" }
  end
end
