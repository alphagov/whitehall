require 'test_helper'

class Admin::EditionWorkflowControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @user = login_as(:departmental_editor)
  end

  test 'publish publishes the given edition on behalf of the current user and redirects back to filtered search view' do
    session[:document_filters] = session_filters = {
      "type" => "publication",
      "state" => "submitted",
      "page" => "3",
    }

    stub_publishing_api_registration_for(submitted_edition)
    post :publish, params: { id: submitted_edition, lock_version: submitted_edition.lock_version }

    assert_redirected_to admin_editions_path(session_filters)
    assert_equal "The document #{submitted_edition.title} has been published", flash[:notice]
    assert submitted_edition.reload.published?
    assert_equal @user, submitted_edition.published_by
  end

  test 'publish redirects back to the edition with an error message if edition cannot be published' do
    published_edition = create(:published_publication)

    post :publish, params: { id: published_edition, lock_version: published_edition.lock_version }
    assert_redirected_to admin_publication_path(published_edition)
    assert_equal 'An edition that is published cannot be published', flash[:alert]
  end

  test 'publish redirects back to the edition with an error message if the edition is stale' do
    old_lock_version = submitted_edition.lock_version
    submitted_edition.touch
    post :publish, params: { id: submitted_edition, lock_version: old_lock_version }

    assert_redirected_to admin_publication_path(submitted_edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'publish responds with 422 if missing a lock version' do
    post :publish, params: { id: submitted_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'GET #confirm_force_publish renders force publishing form'do
    get :confirm_force_publish, params: { id: draft_edition, lock_version: draft_edition.lock_version }

    assert_response :success
    assert_template :confirm_force_publish
  end

  test 'GET #confirm_force_publish redirects when edition must tagged be taxons but is not' do
    publishing_api_has_links(
      "content_id" => draft_edition.content_id,
      "links" => {
        "taxons" => [],
      },
      "version" => 1
    )

    Publication.any_instance.stubs(:can_be_tagged_to_taxonomy?).returns(true)

    get :confirm_force_publish, params: { id: draft_edition, lock_version: draft_edition.lock_version }

    assert_response :redirect
  end

  test 'POST #force_publish force publishes the edition' do
    stub_publishing_api_registration_for(draft_edition)
    post :force_publish, params: { id: draft_edition, lock_version: draft_edition.lock_version, reason: 'Urgent change' }

    assert_redirected_to admin_editions_path(state: :published)
    assert draft_edition.reload.force_published?
  end

  test 'POST #force_publish without a reason is not allowed' do
    post :force_publish, params: { id: draft_edition, lock_version: draft_edition.lock_version }

    assert_redirected_to admin_publication_path(draft_edition)
    assert_equal 'You cannot force publish a document without a reason', flash[:alert]
    assert draft_edition.reload.draft?
  end

  test 'schedule schedules the given edition on behalf of the current user' do
    editor = create(:departmental_editor)
    submitted_edition(submitter: editor, scheduled_publication: 1.day.from_now)
    post :schedule, params: { id: submitted_edition, lock_version: submitted_edition.lock_version }

    assert_redirected_to admin_editions_path(state: :scheduled)
    assert submitted_edition.reload.scheduled?
    assert_equal "The document #{submitted_edition.title} has been scheduled for publication", flash[:notice]
  end

  test 'schedule redirects back to the edition with an error message if scheduling reports a failure' do
    scheduled_edition = create(:submitted_publication)
    post :schedule, params: { id: scheduled_edition, lock_version: scheduled_edition.lock_version }

    assert_redirected_to admin_publication_path(scheduled_edition)
    assert_equal "This edition does not have a scheduled publication date set", flash[:alert]
  end

  test 'schedule redirects back to the edition with an error message if the edition is stale' do
    old_lock_version = submitted_edition(scheduled_publication: 1.day.from_now).lock_version
    acting_as(submitted_edition.creator) { submitted_edition.touch }
    post :schedule, params: { id: submitted_edition, lock_version: old_lock_version }

    assert_redirected_to admin_publication_path(submitted_edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'schedule responds with 422 if missing a lock version' do
    post :schedule, params: { id: draft_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'POST :force_schedule force schedules the edition' do
    draft_edition.update_attribute(:scheduled_publication, 1.day.from_now)
    post :force_schedule, params: { id: draft_edition, lock_version: draft_edition.lock_version }

    assert_redirected_to admin_editions_path(state: :scheduled)
    assert draft_edition.reload.scheduled?
    assert draft_edition.force_published?
  end

  test 'unschedule unschedules the given edition on behalf of the current user' do
    scheduled_edition = create(:scheduled_publication)
    post :unschedule, params: { id: scheduled_edition, lock_version: scheduled_edition.lock_version }

    assert_redirected_to admin_editions_path(state: :submitted)
    assert scheduled_edition.reload.submitted?
  end

  test 'unschedule redirects back to the edition with an error message if unscheduling reports a failure' do
    post :unschedule, params: { id: draft_edition, lock_version: draft_edition.lock_version }
    assert_redirected_to admin_publication_path(draft_edition)
    assert_equal 'This edition is not scheduled for publication', flash[:alert]
  end

  test 'unschedule responds with 422 if missing a lock version' do
    post :unschedule, params: { id: draft_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'submit submits the edition' do
    draft_edition = create(:draft_publication)
    post :submit, params: { id: draft_edition, lock_version: draft_edition.lock_version }

    assert_redirected_to admin_publication_path(draft_edition)
    assert draft_edition.reload.submitted?
    assert_equal "Your document has been submitted for review by a second pair of eyes", flash[:notice]
  end

  test 'submit rejects stale editions' do
    draft_edition = create(:draft_publication)
    old_lock_version = draft_edition.lock_version
    draft_edition.touch
    post :submit, params: { id: draft_edition, lock_version: old_lock_version }

    assert_redirected_to admin_publication_path(draft_edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'submit redirects back to the edition with an error message on validation error' do
    draft_edition.update_attribute(:summary, nil)
    post :submit, params: { id: draft_edition, lock_version: draft_edition.lock_version }

    assert_redirected_to admin_publication_path(draft_edition)
    assert_equal "Unable to submit this edition because it is invalid (Summary can't be blank). Please edit it and try again.", flash[:alert]
  end

  test 'submit responds with 422 if missing a lock version' do
    post :submit, params: { id: draft_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'reject redirects to the new editorial remark page to explain why the edition has been rejected' do
    submitted_publication = create(:submitted_publication)
    post :reject, params: { id: submitted_publication, lock_version: submitted_publication.lock_version }

    assert_redirected_to new_admin_edition_editorial_remark_path(submitted_publication)
    assert submitted_publication.reload.rejected?
  end

  test 'reject notifies authors of rejection via email' do
    submitted_publication = create(:submitted_publication)
    post :reject, params: { id: submitted_publication, lock_version: submitted_publication.lock_version }

    assert_match %r[\'#{submitted_publication.title}\' was rejected by], ActionMailer::Base.deliveries.last.body.to_s
  end

  test 'reject responds with 422 if missing a lock version' do
    post :reject, params: { id: draft_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'approve_retrospectively marks the document as having been approved retrospectively and redirects back to he edition' do
    editor = create(:departmental_editor)
    acting_as(editor) { force_publish(draft_edition) }
    post :approve_retrospectively, params: { id: draft_edition, lock_version: draft_edition.lock_version }

    assert_redirected_to admin_publication_path(draft_edition)
    assert_equal "Thanks for reviewing; this document is no longer marked as force-published", flash[:notice]
  end

  test 'approve_retrospectively responds with 422 if missing a lock version' do
    post :approve_retrospectively, params: { id: draft_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test "confirm_unpublish loads the edition and renders the confirm page" do
    login_as(create(:managing_editor))
    publication = create(:published_publication)
    get :confirm_unpublish, params: { id: publication, lock_version: publication.lock_version }

    assert_response :success
    assert_template :confirm_unpublish
    assert_equal publication, assigns(:edition)
  end

  test 'unpublish is forbidden to non-Managing editors editors' do
    post :unpublish, params: { id: published_edition, lock_version: published_edition.lock_version }
    assert_response :forbidden
  end

  test 'unpublish unpublishes the edition redirects back with a message' do
    login_as create(:managing_editor)
    unpublish_params = {
        unpublishing_reason_id: UnpublishingReason::PublishedInError.id,
        explanation: 'Was classified'
      }
    post :unpublish, params: { id: published_edition, lock_version: published_edition.lock_version, unpublishing: unpublish_params }

    assert_redirected_to admin_publication_path(published_edition)
    assert_equal "This document has been unpublished and will no longer appear on the public website", flash[:notice]
    assert_equal 'Was classified', published_edition.reload.unpublishing.explanation
  end

  test '#unpublish when the edition is being withdrawn sets an appropriate flash message for the user' do
    login_as create(:managing_editor)
    unpublish_params = {
        unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
        explanation: 'No longer government publication'
      }
    post :unpublish, params: { id: published_edition, lock_version: published_edition.lock_version, unpublishing: unpublish_params }

    assert_redirected_to admin_publication_path(published_edition)
    assert_equal "This document has been marked as withdrawn", flash[:notice]
    assert_equal 'No longer government publication', published_edition.reload.unpublishing.explanation
  end

  test '#unpublish when there are validation errors re-renders the unpublish form' do
    login_as create(:managing_editor)
    unpublish_params = {
        unpublishing_reason_id: UnpublishingReason::Consolidated.id,
        alternative_url: ''
      }
    post :unpublish, params: { id: published_edition, lock_version: published_edition.lock_version, unpublishing: unpublish_params }
    assert_response :success
    assert_template :confirm_unpublish
    assert_match %r[Alternative url must be provided], flash[:alert]
    assert published_edition.reload.published?
  end

  test 'unpublish responds with 422 if missing a lock version' do
    login_as create(:managing_editor)
    post :unpublish, params: { id: published_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test 'convert_to_draft turns the given edition into a draft and redirects back to the imported editions page' do
    imported_edition = create(:imported_edition)
    post :convert_to_draft, params: { id: imported_edition, lock_version: imported_edition.lock_version }

    assert_equal "The imported document #{imported_edition.title} has been converted into a draft", flash[:notice]
    assert_redirected_to admin_editions_path(state: :imported)
  end

  test 'convert_to_draft responds with 422 if missing a lock version' do
    post :convert_to_draft, params: { id: imported_edition }

    assert_response :unprocessable_entity
    assert_equal 'All workflow actions require a lock version', response.body
  end

  test "should prevent access to inaccessible editions" do
    protected_edition = create(:draft_publication, :access_limited)

    post :submit, params: { id: protected_edition.id }
    assert_response :forbidden

    post :approve_retrospectively, params: { id: protected_edition.id }
    assert_response :forbidden

    post :reject, params: { id: protected_edition.id }
    assert_response :forbidden

    post :publish, params: { id: protected_edition.id }
    assert_response :forbidden

    post :unpublish, params: { id: protected_edition.id }
    assert_response :forbidden

    post :schedule, params: { id: protected_edition.id }
    assert_response :forbidden

    post :unschedule, params: { id: protected_edition.id }
    assert_response :forbidden
  end

private

  def submitted_edition(options = {})
    @submitted_edition ||= create(:submitted_publication, options)
  end

  def draft_edition
    @draft_edition ||= create(:draft_publication)
  end

  def published_edition
    @published_edition ||= create(:published_publication)
  end

  def imported_edition
    @imported_edition ||= create(:imported_edition)
  end

  def withdrawn_edition
    @withdrawn_edition ||= create(:withdrawn_edition, major_change_published_at: Time.zone.now)
  end
end
