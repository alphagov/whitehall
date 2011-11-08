require "test_helper"

class CountriesControllerTest < ActionController::TestCase
  test 'is an application controller' do
    assert @controller.is_a?(ApplicationController), "the controller should have the behaviour of an ApplicationController"
  end

  test "index should display a list of countries" do
    bat = create(:country, name: "British Antarctic Territory")
    png = create(:country, name: "Papua New Guinea")

    get :index

    assert_select ".countries" do
      assert_select_object bat
      assert_select_object png
    end
  end
end