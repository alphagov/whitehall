module ControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_be_an_admin_controller
      test "should be an admin controller" do
        assert @controller.is_a?(Admin::BaseController), "the controller should be an admin controller"
      end
    end

    def should_require_fatality_handling_permission_to_access(edition_type, *actions)
      test "requires the ability to handle fatalities to access" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        login_as :writer
        actions.each do |action|
          get action, params: { id: edition.id }
          assert_response :forbidden
        end
      end
    end
  end

  def govspeak_transformation_fixture(transformation)
    methods_to_stub = %w[
      bare_govspeak_to_html
      bare_govspeak_to_admin_html
    ]
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
