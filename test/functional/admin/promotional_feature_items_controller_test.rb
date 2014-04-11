require 'test_helper'

class Admin::PromotionalFeatureItemsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @promotional_feature = create(:promotional_feature)
    @organisation = @promotional_feature.organisation
  end

  should_be_an_admin_controller

  test 'GET :new loads the organisation and feature and instantiates a new item and link' do
    get :new, organisation_id: @organisation, promotional_feature_id: @promotional_feature

    assert_response :success
    assert_template :new
    assert_equal @organisation, assigns(:organisation)
    assert_equal @promotional_feature, assigns(:promotional_feature)
    assert assigns(:promotional_feature_item).is_a?(PromotionalFeatureItem)
    assert_equal 1, assigns(:promotional_feature_item).links.size
  end

  test 'POST :create saves the new promotional item to the feature' do
    post :create, organisation_id: @organisation, promotional_feature_id: @promotional_feature,
                  promotional_feature_item: { summary: 'Summary text', image_alt_text: 'Alt text', image: fixture_file_upload('minister-of-funk.960x640.jpg')}

    assert promotional_feature_item = @promotional_feature.reload.promotional_feature_items.first
    assert_equal 'Alt text', promotional_feature_item.image_alt_text
    assert_equal 'minister-of-funk.960x640.jpg', promotional_feature_item.image.file.filename

    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, @promotional_feature)
    assert_equal 'Feature item added.', flash[:notice]
  end

  test 'GET :edit loads the item and its links renders the template' do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature)
    link = create(:promotional_feature_link, promotional_feature_item: promotional_feature_item)
    get :edit, organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item

    assert_response :success
    assert_template :edit
    assert_equal @organisation, assigns(:organisation)
    assert_equal @promotional_feature, assigns(:promotional_feature)
    assert_equal promotional_feature_item, assigns(:promotional_feature_item)
    assert_equal [link], assigns(:promotional_feature_item).links
  end

  test 'GET :edit assigns a blank link if the item does not already have one' do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature)
    get :edit, organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item

    assert_response :success
    assert_template :edit
    assert link = assigns(:promotional_feature_item).links.first
    assert link.new_record?
    assert link.is_a?(PromotionalFeatureLink)
  end

  test 'PUT :update updates the item and redirects to the feature' do
    link = create(:promotional_feature_link)
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature, links: [link])

    put :update, organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item,
                  promotional_feature_item: {
                    summary: 'Updated summary',
                    links_attributes: { '0' => { url: link.url, text: link.text, id: link.id, _destroy: false } }
                  }

    assert_equal 'Updated summary', promotional_feature_item.reload.summary
    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, @promotional_feature)
    assert_equal 'Feature item updated.', flash[:notice]
  end

  test 'PUT :update re-renders edit if the feature item does not save' do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature, summary: 'Old summary')
    put :update, organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item,
                  promotional_feature_item: { summary: ''}

    assert_template :edit
    assert_equal 'Old summary', promotional_feature_item.reload.summary
  end

  test 'DELETE :destroy deletes the promotional item' do
    promotional_feature_item = create(:promotional_feature_item, promotional_feature: @promotional_feature)
    delete :destroy, organisation_id: @organisation, promotional_feature_id: @promotional_feature, id: promotional_feature_item

    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, @promotional_feature)
    refute PromotionalFeatureItem.exists?(promotional_feature_item)
    assert_equal 'Feature item deleted.', flash[:notice]
  end
end
