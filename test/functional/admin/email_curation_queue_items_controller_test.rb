require 'test_helper'

class Admin::EmailCurationQueueItemsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test "GET on :index fetches all the email curation queue items, in newset first order" do
    item_1 = create(:email_curation_queue_item, created_at: 1.day.ago)
    item_2 = create(:email_curation_queue_item, created_at: 10.minutes.ago)
    item_3 = create(:email_curation_queue_item, created_at: 16.hours.ago)
    get :index

    assert_response :success
    assert_template :index
    assert_equal [item_2, item_3, item_1], assigns(:email_curation_queue_items)
  end

  test "GET on :edit loads the specificed queue item" do
    item = create(:email_curation_queue_item)
    get :edit, id: item

    assert_response :success
    assert_template :edit
    assert_equal item, assigns(:email_curation_queue_item)
  end

  test 'PUT on :update updates the details of the specified queue item' do
    item = create(:email_curation_queue_item, title: 'An irrelevant title', summary: 'An irrelevant summary')
    put :update, id: item, email_curation_queue_item: { title: 'A more relevant title', summary: 'A more relevant summary' }

    assert_redirected_to admin_email_curation_queue_items_path

    item.reload

    assert_equal 'A more relevant title', item.title
    assert_equal 'A more relevant summary', item.summary
  end

  test "PUT on :update re-renders the error form and doesn't update the db record with invalid data" do
    item = create(:email_curation_queue_item, title: 'An irrelevant title', summary: 'An irrelevant summary')
    put :update, id: item, email_curation_queue_item: { title: '', summary: '' }

    assert_response :success
    assert_template :edit
    refute assigns(:email_curation_queue_item).errors.empty?

    item.reload
    assert_equal 'An irrelevant title', item.title
    assert_equal 'An irrelevant summary', item.summary
  end

  test 'DELETE on :destroy removes the specified queue item' do
    item = create(:email_curation_queue_item)
    delete :destroy, id: item

    assert_redirected_to admin_email_curation_queue_items_path

    refute EmailCurationQueueItem.exists?(item)
  end

  test 'POST on :send_to_subscribers invokes the Whitehall::GovUkDelivery::Worker with the queue item and removes it from the queue' do
    item = create(:email_curation_queue_item)
    Whitehall::GovUkDelivery::Worker.expects(:notify!).with(item.edition, item.notification_date, item.title, item.summary)
    post :send_to_subscribers, id: item

    refute EmailCurationQueueItem.exists?(item)
  end
end
