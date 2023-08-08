module ControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    LAYOUT_ALWAYS_DESIGN_SYSTEM = %w[reorder update_order confirm_destroy].freeze

    def should_be_an_admin_controller
      test "should be an admin controller" do
        assert @controller.is_a?(Admin::BaseController), "the controller should be an admin controller"
      end
    end

    def should_render_bootstrap_implementation_with_preview_next_release
      test "should render the admin layout when the user has 'Preview next release' permission" do
        return unless @controller.class.private_method_defined?(:get_layout)

        user = login_as(:writer)
        user.permissions << "Preview next release"

        # Get all non-inherited controller actions and test they use the admin layout.
        @controller.class.instance_methods(false).map(&:to_s).reject { |action| LAYOUT_ALWAYS_DESIGN_SYSTEM.include?(action) }.each do |action|
          @controller.action_name = action
          assert_equal "admin", @controller.send(:get_layout), "#{@controller.class}##{action} is not rendering the admin layout"
        end
      end
    end

    def should_require_fatality_handling_permission_to_access(edition_type, *actions)
      test "requires the ability to handle fatalities to access" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        login_as :writer
        actions.each do |action|
          get action, params: { id: edition.id }
          assert_response 403
        end
      end
    end
  end

  def govspeak_transformation_fixture(transformation)
    methods_to_stub = {
      GovspeakHelper => "bare_govspeak_to_html",
      Admin::AdminGovspeakHelper => "bare_govspeak_to_admin_html",
    }
    begin
      methods_to_stub.each do |helper_module, method_name|
        helper_module.send(:alias_method, "orig_#{method_name}".to_sym, method_name.to_sym)
        helper_module.send(:define_method, method_name.to_sym) do |govspeak, *args|
          transformation[govspeak] || transformation[:default] || send("orig_#{method_name}".to_sym, govspeak, *args)
        end
      end
      yield
    ensure
      methods_to_stub.each do |helper_module, method_name|
        helper_module.send(:alias_method, method_name.to_sym, "orig_#{method_name}".to_sym)
        helper_module.send(:remove_method, "orig_#{method_name}".to_sym)
      end
    end
  end
end
