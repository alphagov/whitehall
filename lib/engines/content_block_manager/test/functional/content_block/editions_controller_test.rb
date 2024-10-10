require "test_helper"

class ContentBlockManager::ContentBlock::EditionsControllerTest < ActionController::TestCase
  test "should inherit from base controller" do
    assert @controller.is_a?(ContentBlockManager::BaseController),
           "the controller should inherit from the object store's base controller"
  end
end
