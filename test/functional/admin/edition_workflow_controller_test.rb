require 'test_helper'

class Admin::EditionWorkflowControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @edition = build(:submitted_policy)
    @edition.stubs(id: 1234, new_record?: false)
    @user = login_as(:departmental_editor)
    Edition.stubs(:find).with(@edition.to_param).returns(@edition)
  end

  test 'publish publishes the given edition on behalf of the current user' do
    @edition.expects(:publish_as).with(@user, force: false).returns(true)
    post :publish, id: @edition
  end

  test 'publish reports that the document has been published' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition
    assert_equal "The document #{@edition.title} has been published", flash[:notice]
  end

  test 'publish redirects back to the published edition index' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition
    assert_redirected_to admin_documents_path(state: :published)
  end

  test 'publish passes through the force flag' do
    @edition.expects(:publish_as).with(@user, force: true).returns(true)
    post :publish, id: @edition, force: true
  end

  test 'publish sets change note on edition' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition, document: {
      change_note: "change-note"
    }

    assert_equal "change-note", @edition.change_note
  end

  test 'publish sets minor change flag on edition' do
    @edition.stubs(:publish_as).returns(true)
    post :publish, id: @edition, document: {
      minor_change: true
    }

    assert_equal true, @edition.minor_change
  end

  test 'publish redirects back to the edition with an error message if publishing reports a failure' do
    @edition.stubs(:publish_as).returns(false)
    @edition.errors.add(:base, 'Edition could not be published')
    post :publish, id: @edition
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'Edition could not be published', flash[:alert]
  end

  test 'publish sets lock version on edition before attempting to publish to guard against stale objects' do
    lock_before_publishing = sequence('lock-before-publishing')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_publishing)
    @edition.expects(:publish_as).in_sequence(lock_before_publishing).returns(true)
    post :publish, id: @edition, document: {
      lock_version: 92
    }
  end

  test 'publish redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:publish_as).raises(ActiveRecord::StaleObjectError)
    post :publish, id: @edition
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'submit submits the edition' do
    @edition.expects(:submit!)
    post :submit, id: @edition
  end

  test 'submit redirects back to the edition with a message indicating it has been submitted' do
    @edition.stubs(:submit!)
    post :submit, id: @edition

    assert_redirected_to admin_policy_path(@edition)
    assert_equal "Your document has been submitted for review by a second pair of eyes", flash[:notice]
  end

  test 'submit sets lock version on edition before attempting to submit to guard against submitting stale objects' do
    lock_before_submitting = sequence('lock-before-submitting')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_submitting)
    @edition.expects(:submit!).in_sequence(lock_before_submitting).returns(true)
    post :submit, id: @edition, document: {
      lock_version: 92
    }
  end

  test 'submit redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:submit!).raises(ActiveRecord::StaleObjectError)
    post :submit, id: @edition
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end

  test 'reject rejects the edition' do
    @edition.expects(:reject!)
    post :reject, id: @edition
  end

  test 'reject redirects to the new editorial remark page to explain why the edition has been rejected' do
    @edition.stubs(:reject!)
    post :reject, id: @edition

    assert_redirected_to new_admin_document_editorial_remark_path(@edition)
  end

  test 'reject sets lock version on edition before attempting to reject to guard against rejecting stale objects' do
    lock_before_rejecting = sequence('lock-before-rejecting')
    @edition.expects(:lock_version=).with('92').in_sequence(lock_before_rejecting)
    @edition.expects(:reject!).in_sequence(lock_before_rejecting).returns(true)
    post :reject, id: @edition, document: {
      lock_version: 92
    }
  end

  test 'reject redirects back to the edition with an error message if a stale object error is thrown' do
    @edition.stubs(:reject!).raises(ActiveRecord::StaleObjectError)
    post :reject, id: @edition
    assert_redirected_to admin_policy_path(@edition)
    assert_equal 'This document has been edited since you viewed it; you are now viewing the latest version', flash[:alert]
  end
end