module ControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def test_controller_is_a(controller_class)
      test "is a #{controller_class.name.gsub(%r{::}, ' ')}" do
        assert @controller.is_a?(controller_class), "the controller should have the behaviour of a #{controller_class}"
      end
    end
  end
end