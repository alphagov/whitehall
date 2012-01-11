module ControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_be_an_admin_controller
      test "should be an admin controller" do
        assert @controller.is_a?(Admin::BaseController), "the controller should be an admin controller"
      end
    end

    def should_be_a_public_facing_controller
      test "should be a public facing controller" do
        assert @controller.is_a?(PublicFacingController), "the controller should be a public facing controller"
      end
    end
  end
end