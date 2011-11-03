require "test_helper"

class Admin::ExampleController < Admin::BaseController
  def show
    render text: "access granted"
  end
end

class Admin::ExampleControllerTest < ActionController::TestCase
  test "redirects to login when not authenticated" do
    with_example_routing do
      get :show

      assert_login_required
    end
  end

  test "allows action to be called when authenticated" do
    with_example_routing do
      login_as :policy_writer

      get :show

      assert_equal "access granted", @response.body
    end
  end

  private

  def with_example_routing
    with_routing do |set|
      set.draw do
        namespace :admin do
          match "example", to: "example#show"
        end
        match 'login' => 'sessions#new', via: :get
      end
      yield
    end
  end
end