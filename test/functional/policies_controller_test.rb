require 'test_helper'

class PoliciesControllerTest < ActionController::TestCase
  test 'show policy with one draft edition' do
    draft_edition = FactoryGirl.create(:draft_edition)
    get :show, id: draft_edition.policy.to_param

    assert_response :not_found
  end
  
  test 'show policy with one published edition' do
    published_edition = FactoryGirl.create(:published_edition)
    get :show, id: published_edition.policy.to_param
  
    assert_response :success
    assert_equal published_edition, assigns[:edition]
  end
  
  test 'show policy with one published edition and one draft edition' do
    published_edition = FactoryGirl.create(:published_edition)
    edition = FactoryGirl.create(:draft_edition, policy: published_edition.policy)
    get :show, id: published_edition.policy.to_param
  
    assert_response :success
    assert_equal published_edition, assigns[:edition]
  end
  
  test 'show policy with one published edition and one archived edition' do
    archived_edition = FactoryGirl.create(:archived_edition)
    published_edition = FactoryGirl.create(:published_edition, policy: archived_edition.policy)
  
    get :show, id: archived_edition.policy.to_param
  
    assert_response :success
    assert_equal published_edition, assigns[:edition]
  end
  
  test 'index policy with one draft edition' do
    draft_edition = FactoryGirl.create(:draft_edition)
    get :index
  
    assert_equal [], assigns[:editions]
  end
  
  test 'index policy with one published edition' do
    published_edition = FactoryGirl.create(:published_edition)
    get :index
  
    assert_response :success
    assert_equal [published_edition], assigns[:editions]
  end
  
  test 'index policy with one published edition and one draft edition' do
    published_edition = FactoryGirl.create(:published_edition)
    edition = FactoryGirl.create(:draft_edition, policy: published_edition.policy)
    get :index
  
    assert_response :success
    assert_equal [published_edition], assigns[:editions]
  end
  
  test 'index policy with one published edition and one archived edition' do
    archived_edition = FactoryGirl.create(:archived_edition)
    published_edition = FactoryGirl.create(:published_edition, policy: archived_edition.policy)
  
    get :index
  
    assert_response :success
    assert_equal [published_edition], assigns[:editions]
  end
end
