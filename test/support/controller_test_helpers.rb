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
    GovspeakHelper.send(:alias_method, "orig_bare_govspeak_to_html".to_sym, "bare_govspeak_to_html".to_sym)
    GovspeakHelper.send(:define_method, "bare_govspeak_to_html".to_sym) do |govspeak, *args|
      transformation[govspeak] || transformation[:default] || send("orig_bare_govspeak_to_html".to_sym, govspeak, *args)
    end
    yield
  ensure
    GovspeakHelper.send(:alias_method, "bare_govspeak_to_html".to_sym, "orig_bare_govspeak_to_html".to_sym)
    GovspeakHelper.send(:remove_method, "orig_bare_govspeak_to_html".to_sym)
  end
end
