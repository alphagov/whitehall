require "test_helper"

class ContentObjectStore::ContentBlockEditionsControllerTest < ActionController::TestCase
  test "should inherit from base controller" do
    assert @controller.is_a?(ContentObjectStore::BaseController),
           "the controller should inherit from the object store's base controller"
  end
end
