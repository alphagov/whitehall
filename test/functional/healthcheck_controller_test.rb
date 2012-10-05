require "test_helper"

class HealthcheckControllerTest < ActionController::TestCase
  test "returns success on request" do
    get :check
    assert_equal 200, response.status
  end

  test "raises 500 on lack of database" do
    Edition.stubs(:count).raises(Mysql2::Error.new('Database has gone away'))
    assert_raise Mysql2::Error do
      get :check
    end
  end
end
