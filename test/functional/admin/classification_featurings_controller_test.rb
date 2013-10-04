require 'test_helper'

class Admin::ClassificationFeaturingsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @topic = create(:topic)
    login_as :policy_writer
  end

  test "PUT :order saves the new order of featurings" do
    feature1 = create(:classification_featuring, classification: @topic)
    feature2 = create(:classification_featuring, classification: @topic)
    feature3 = create(:classification_featuring, classification: @topic)

    put :order, topic_id: @topic, ordering: {
                                        feature1.id.to_s => '1',
                                        feature2.id.to_s => '2',
                                        feature3.id.to_s => '0'
                                      }

    assert_response :redirect
    assert_equal [feature3, feature1, feature2], @topic.reload.classification_featurings
  end
end
