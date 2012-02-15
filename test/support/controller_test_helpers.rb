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
  
  def govspeak_transformation_fixture(transformation, &block)
    methods_to_stub = %w{govspeak_to_html govspeak_to_admin_html}
    begin
      methods_to_stub.each do |method_name|
        GovspeakHelper.send(:alias_method, "orig_#{method_name}".to_sym, method_name.to_sym)
        GovspeakHelper.send(:define_method, method_name.to_sym) do |govspeak, *args|
          transformation[govspeak] || transformation[:default] || send("orig_#{method_name}".to_sym, govspeak, *args)
        end
      end
      yield
    ensure
      methods_to_stub.each do |method_name|
        GovspeakHelper.send(:alias_method, method_name.to_sym, "orig_#{method_name}".to_sym)
        GovspeakHelper.send(:remove_method, "orig_#{method_name}".to_sym)
      end
    end
  end

end