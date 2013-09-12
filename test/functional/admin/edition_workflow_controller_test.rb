require 'test_helper'

class Admin::EditionWorkflowControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @edition = build(:submitted_policy, document: build(:document))
    @edition.document.stubs(:to_param).returns('policy-slug')
    @edition.stubs(id: 1234, new_record?: false)
    @user = login_as(:departmental_editor)
    Edition.stubs(:find).with(@edition.to_param).returns(@edition)
  end

  test 'publish publishes the given edition on behalf of the current user' do
    @edition.expects(:publish_as).with(@user, force: false).returns(true)
    post :publish, id: @edition, lock_version: 1
  end

  test 'publish reports that the document has been published' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition, lock_version: 1
    assert_equal "The document #{@edition.title} has been published", flash[:notice]
  end

  test 'publish redirects back to the published edition index' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition, lock_version: 1
    assert_redirected_to admin_editions_path(state: :published)
  end

  test 'publish notifies authors of publication via email' do
    author = build(:user)
    @edition.stubs(:publish_as).returns(true)
    @edition.stubs(:authors).returns([author])
    email = stub('email')
    Notifications.expects(:edition_published).with(author, @edition, admin_policy_url(@edition), policy_url(@edition.document)).returns(email)
    email.expects(:deliver)
    post :publish, id: @edition, lock_version: 1
  end

  test 'publish only notifies authors with emails' do
    author_with_email, author_without_email = build(:user), build(:user, email: '')
    @edition.stubs(:publish_as).returns(true)
    @edition.stubs(:authors).returns([author_with_email, author_without_email])
    Notifications.expects(:edition_published).with(author_with_email, anything, anything, anything).returns(stub_everything('email'))
    post :publish, id: @edition, lock_version: 1
  end

  test 'publish only notifies authors once' do
    author = build(:user)
    @edition.stubs(:publish_as).returns(true)
    @edition.stubs(:authors).returns([author, author])
    email = stub('email')
    Notifications.expects(:edition_published).once.with(author, @edition, admin_policy_url(@edition), policy_url(@edition.document)).returns(email)
    email.expects(:deliver)
    post :publish, id: @edition, lock_version: 1
  end

  test 'publish doesn\'t notify authors if they instigated the rejection' do
    @edition.stubs(:publish_as).returns(true)
    @edition.stubs(:authors).returns([@user])
    Notifications.expects(:edition_published).never
    post :publish, id: @edition, lock_version: 1
  end

  test 'publish passes through the force flag' do
    @edition.expects(:publish_as).with(@user, force: true).returns(true)
    post :publish, id: @edition, force: true, lock_version: 1, reason: "Just because"
  end

  test 'publish sets change note on edition' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition, lock_version: 1, edition: {
      change_note: "change-note"
    }

    assert_equal "change-note", @edition.change_note
  end

  test 'publish sets minor change flag on edition' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition, lock_version: 1, edition: {
      minor_change: true
    }

    assert_equal true, @edition.minor_change
  end

  test 'publish redirects back to the edition with an error message if publishing reports a failure' do
    @edition.stubs(:publish_as).returns(false)
    @edition.errors.add(:base, 'Edition could not be published')
    post :publish, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'Edition could not be published', flash[:alert]
  end

  test 'publish sets lock version on edition before attempting to publish to guard against stale objects' do
    lock_before_publishing = sequence('lock-before-publishing')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_publishing)
    @edition.expects(:publish_as).in_sequence(lock_before_publishing).returns(true)
    post :publish, id: @edition, lock_version: 92
  end

  test 'publish redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:publish_as).raises(ActiveRecord::StaleObjectError.new(@edition, :publish_as))
    post :publish, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'publish responds with 422 if missing a lock version' do
    post :publish, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'schedule schedules the given edition on behalf of the current user' do
    @edition.expects(:schedule_as).with(@user, force: false).returns(true)
    post :schedule, id: @edition, lock_version: 1
  end

  test 'schedule reports that the document has been scheduled' do
    @edition.stubs(:schedule_as).returns(true)
    post :schedule, id: @edition, lock_version: 1
    assert_equal "The document #{@edition.title} has been scheduled for publication", flash[:notice]
  end

  test 'schedule redirects back to the scheduled edition index' do
    @edition.stubs(:schedule_as).returns(true)
    post :schedule, id: @edition, lock_version: 1
    assert_redirected_to admin_editions_path(state: :scheduled)
  end

  test 'schedule passes through the force flag' do
    @edition.expects(:schedule_as).with(@user, force: true).returns(true)
    post :schedule, id: @edition, force: true, lock_version: 1
  end

  test 'schedule redirects back to the edition with an error message if scheduling reports a failure' do
    @edition.stubs(:schedule_as).returns(false)
    @edition.errors.add(:base, 'Edition could not be scheduled')
    post :schedule, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'Edition could not be scheduled', flash[:alert]
  end

  test 'schedule sets lock version on edition before attempting to schedule to guard against stale objects' do
    lock_before_scheduling = sequence('lock-before-scheduling')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_scheduling)
    @edition.expects(:schedule_as).in_sequence(lock_before_scheduling).returns(true)
    post :schedule, id: @edition, lock_version: 92
  end

  test 'schedule redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:schedule_as).raises(ActiveRecord::StaleObjectError.new(@edition, :schedule))
    post :schedule, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'schedule responds with 422 if missing a lock version' do
    post :schedule, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'unschedule unschedules the given edition on behalf of the current user' do
    @edition.expects(:unschedule_as).with(@user).returns(true)
    post :unschedule, id: @edition, lock_version: 1
  end

  test 'unschedule redirects back to the submitted edition index' do
    @edition.stubs(:unschedule_as).returns(true)
    post :unschedule, id: @edition, lock_version: 1
    assert_redirected_to admin_editions_path(state: :submitted)
  end

  test 'unschedule redirects back to the edition with an error message if unscheduling reports a failure' do
    @edition.stubs(:unschedule_as).returns(false)
    @edition.errors.add(:base, 'Edition could not be unscheduled')
    post :unschedule, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'Edition could not be unscheduled', flash[:alert]
  end

  test 'unschedule sets lock version on edition before attempting to unschedule to guard against stale objects' do
    lock_before_unscheduling = sequence('lock-before-unscheduling')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_unscheduling)
    @edition.expects(:unschedule_as).in_sequence(lock_before_unscheduling).returns(true)
    post :unschedule, id: @edition, lock_version: 92
  end

  test 'unschedule redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:unschedule_as).raises(ActiveRecord::StaleObjectError.new(@edition, :unschedule))
    post :unschedule, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'unschedule responds with 422 if missing a lock version' do
    post :unschedule, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'submit submits the edition' do
    @edition.expects(:submit!)
    post :submit, id: @edition, lock_version: 1
  end

  test 'submit redirects back to the edition with a message indicating it has been submitted' do
    @edition.stubs(:submit!)
    post :submit, id: @edition, lock_version: 1

    assert_redirected_to admin_policy_path(@edition)
    assert_equal "Your document has been submitted for review by a second pair of eyes", flash[:notice]
  end

  test 'submit sets lock version on edition before attempting to submit to guard against submitting stale objects' do
    lock_before_submitting = sequence('lock-before-submitting')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_submitting)
    @edition.expects(:submit!).in_sequence(lock_before_submitting).returns(true)
    post :submit, id: @edition, lock_version: 92
  end

  test 'submit redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:submit!).raises(ActiveRecord::StaleObjectError.new(@edition, :submit!))
    post :submit, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'submit redirects back to the edition with an error message on validation error' do
    @edition.errors.add(:change_note, "can't be blank")
    @edition.stubs(:submit!).raises(ActiveRecord::RecordInvalid, @edition)
    post :submit, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal "Unable to submit this edition because it is invalid (Change note can't be blank). Please edit it and try again.", flash[:alert]
  end

  test 'submit responds with 422 if missing a lock version' do
    post :submit, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'reject rejects the edition' do
    @edition.expects(:reject!)
    post :reject, id: @edition, lock_version: 1
  end

  test 'reject redirects to the new editorial remark page to explain why the edition has been rejected' do
    @edition.stubs(:reject!)
    post :reject, id: @edition, lock_version: 1

    assert_redirected_to new_admin_edition_editorial_remark_path(@edition)
  end

  test 'reject notifies authors of rejection via email' do
    author = build(:user)
    @edition.stubs(:reject!)
    @edition.stubs(:authors).returns([author])
    email = stub('email')
    Notifications.expects(:edition_rejected).with(author, @edition, admin_policy_url(@edition)).returns(email)
    email.expects(:deliver)
    post :reject, id: @edition, lock_version: 1
  end

  test 'reject only notifies authors with emails' do
    author_with_email, author_without_email = build(:user), build(:user, email: '')
    @edition.stubs(:reject!)
    @edition.stubs(:authors).returns([author_with_email, author_without_email])
    Notifications.expects(:edition_rejected).with(author_with_email, anything, anything, anything).returns(stub_everything('email'))
    post :reject, id: @edition, lock_version: 1
  end

  test 'reject only notifies authors once' do
    author = build(:user)
    @edition.stubs(:reject!).returns(true)
    @edition.stubs(:authors).returns([author, author])
    email = stub('email')
    Notifications.expects(:edition_rejected).once.with(author, @edition, admin_policy_url(@edition)).returns(email)
    email.expects(:deliver)
    post :reject, id: @edition, lock_version: 1
  end

  test 'reject doesn\'t notify authors if they instigated the rejection' do
    @edition.stubs(:reject!)
    @edition.stubs(:authors).returns([@user])
    Notifications.expects(:edition_rejected).never
    post :reject, id: @edition, lock_version: 1
  end

  test 'reject sets lock version on edition before attempting to reject to guard against rejecting stale objects' do
    lock_before_rejecting = sequence('lock-before-rejecting')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_rejecting)
    @edition.expects(:reject!).in_sequence(lock_before_rejecting).returns(true)
    post :reject, id: @edition, lock_version: 92
  end

  test 'reject redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:reject!).raises(ActiveRecord::StaleObjectError.new(@edtion, :reject!))
    post :reject, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'reject redirects back to the edition with an error message on validation error' do
    @edition.errors.add(:change_note, "can't be blank")
    @edition.stubs(:reject!).raises(ActiveRecord::RecordInvalid, @edition)
    post :reject, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal "Unable to reject this edition because it is invalid (Change note can't be blank). Please edit it and try again.", flash[:alert]
  end

  test 'reject responds with 422 if missing a lock version' do
    post :reject, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'approve_retrospectively marks the document as having been approved retrospectively' do
    @edition.expects(:approve_retrospectively_as)
    post :approve_retrospectively, id: @edition, lock_version: 1
  end

  test 'approve_retrospectively redirects back to the edition with a message' do
    @edition.stubs(:approve_retrospectively_as).returns(true)
    post :approve_retrospectively, id: @edition, lock_version: 1

    assert_redirected_to admin_policy_path(@edition)
    assert_equal "Thanks for reviewing; this document is no longer marked as force-published", flash[:notice]
  end

  test 'approve_retrospectively redirects back to the edition with an error message on validation error' do
    @edition.stubs(:approve_retrospectively_as).returns(false)
    @edition.errors.add(:base, 'Could not approve retrospectively')
    post :approve_retrospectively, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'Could not approve retrospectively', flash[:alert]
  end

  test 'approve_retrospectively sets lock version on edition before attempting to submit to guard against submitting stale objects' do
    lock_before_submitting = sequence('lock-before-submitting')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_submitting)
    @edition.expects(:approve_retrospectively_as).in_sequence(lock_before_submitting).returns(true)
    post :approve_retrospectively, id: @edition, lock_version: 92
  end

  test 'approve_retrospectively redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:approve_retrospectively_as).raises(ActiveRecord::StaleObjectError.new(@edition, :approve_retrospectively_as))
    post :approve_retrospectively, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'approve_retrospectively responds with 422 if missing a lock version' do
    post :approve_retrospectively, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'unpublish unpublishes the edition' do
    controller.stubs(:can?).with(:unpublish, @edition).returns(true)

    @edition.expects(:unpublishable_by?).with(@user).returns(true)
    @edition.expects(:unpublish_edition!)

    post :unpublish, id: @edition, lock_version: 1
  end

  test 'unpublish records the unpublishing reasons' do
    controller.stubs(:can?).with(:unpublish, @edition).returns(true)
    unpublish_params = {
      'unpublishing_reason_id' => '1',
      'explanation' => 'Was classified',
      'alternative_url' => 'http://website.com/alt',
      'document_type' => 'Policy',
      'document_slug' => 'some-slug'
    }

    @edition.expects(:unpublishable_by?).with(@user).returns(true)
    @edition.expects(:build_unpublishing).with(unpublish_params)
    @edition.stubs(:unpublish_edition!)

    post :unpublish, id: @edition.to_param, lock_version: 1, unpublishing: unpublish_params
  end

  test 'unpublish redirects back to the edition with a message' do
    controller.stubs(:can?).with(:unpublish, @edition).returns(true)
    @edition.expects(:unpublish_as).returns(true)

    post :unpublish, id: @edition, lock_version: 1

    assert_redirected_to admin_policy_path(@edition)
    assert_equal "This document has been unpublished and will no longer appear on the public website", flash[:notice]
  end

  test 'unpublish redirects back to the edition with an error message on validation error' do
    controller.stubs(:can?).with(:unpublish, @edition).returns(true)
    @edition.stubs(:unpublish_as).returns(false)
    @edition.errors.add(:base, 'Could not unpublish')
    post :unpublish, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'Could not unpublish', flash[:alert]
  end

  test 'unpublish sets lock version on edition before attempting to unpublish to guard against unpublishing stale objects' do
    controller.stubs(:can?).with(:unpublish, @edition).returns(true)
    lock_before_unpublishing = sequence('lock-before-unpublishing')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_unpublishing)
    @edition.expects(:unpublish_as).in_sequence(lock_before_unpublishing).returns(true)
    post :unpublish, id: @edition, lock_version: 92
  end

  test 'unpublish redirects back to the edition with an error message if a stale object error is thrown' do
    controller.stubs(:can?).with(:unpublish, @edition).returns(true)
    @edition.stubs(:unpublish_as).raises(ActiveRecord::StaleObjectError.new(@edition, :unpublish_as))
    post :unpublish, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'unpublish responds with 422 if missing a lock version' do
    controller.stubs(:can?).with(:unpublish, @edition).returns(true)
    post :unpublish, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'convert_to_draft turns the given edition into a draft' do
    @edition.expects(:convert_to_draft!)
    post :convert_to_draft, id: @edition, lock_version: 1
    assert_equal "The imported document #{@edition.title} has been converted into a draft", flash[:notice]
  end

  test 'convert_to_draft redirects back to the imported edition index' do
    @edition.stubs(:convert_to_draft!)
    post :convert_to_draft, id: @edition, lock_version: 1
    assert_redirected_to admin_editions_path(state: :imported)
  end

  test 'convert_to_draft redirects back to the edition with an error message on validation error' do
    @edition.errors.add(:base, "It isn't ready yet")
    @edition.stubs(:convert_to_draft!).raises(ActiveRecord::RecordInvalid, @edition)
    post :convert_to_draft, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal "Unable to convert this imported edition to a draft because it is invalid (It isn't ready yet). Please edit it and try again.", flash[:alert]
  end

  test 'convert_to_draft redirects back to the edition with an error message when it can\'t be transitioned' do
    @edition.stubs(:convert_to_draft!).raises(Transitions::InvalidTransition, @edition)
    post :convert_to_draft, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal "Unable to convert this imported edition to a draft because it is not ready yet. Please try again.", flash[:alert]
  end

  test 'convert_to_draft sets lock version on edition before attempting to unpublish to guard against unpublishing stale objects' do
    lock_before_unpublishing = sequence('lock-before-unpublishing')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_unpublishing)
    @edition.expects(:convert_to_draft!).in_sequence(lock_before_unpublishing)
    post :convert_to_draft, id: @edition, lock_version: 92
  end

  test 'convert_to_draft redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:convert_to_draft!).raises(ActiveRecord::StaleObjectError.new(@edition, :convert_to_draft!))
    post :convert_to_draft, id: @edition, lock_version: 1
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'convert_to_draft responds with 422 if missing a lock version' do
    post :convert_to_draft, id: @edition
    assert_equal 422, response.status
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test "should prevent access to inaccessible editions" do
    protected_edition = build(:edition, id: "1")
    protected_edition.stubs(:accessible_by?).with(@current_user).returns(false)
    Edition.stubs(:find).with("1").returns(protected_edition)
    controller.stubs(:can?).with(anything, protected_edition).returns(true)

    post :submit, id: protected_edition.id
    assert_response 403
    post :approve_retrospectively, id: protected_edition.id
    assert_response 403
    post :reject, id: protected_edition.id
    assert_response 403
    post :publish, id: protected_edition.id
    assert_response 403
    post :unpublish, id: protected_edition.id
    assert_response 403
    post :schedule, id: protected_edition.id
    assert_response 403
    post :unschedule, id: protected_edition.id
    assert_response 403
  end
end
