require 'test_helper'

module Whitehall::DocumentFilter
  class CleanedParamsTest < ActiveSupport::TestCase
    setup do
      @old_config_value = ActionController::Parameters.action_on_unpermitted_parameters
      ActionController::Parameters.action_on_unpermitted_parameters = false
    end

    teardown do
      ActionController::Parameters.action_on_unpermitted_parameters = @old_config_value
    end

    CleanedParams::PERMITTED_ARRAY_PARAMETER_KEYS.each do |param_key|
      test "converts #{param_key} parameter converted to a hash by Facebook referrer back to an array" do
        raw_params     = build_unclean_params(param_key => { '0' => "#{param_key}-1", '1' => "#{param_key}-2" })
        cleaned_params = CleanedParams.new(raw_params)

        assert_equal ["#{param_key}-1", "#{param_key}-2"], cleaned_params[param_key]
      end
    end

    test "unrecognised scaler parameters are scrubbed" do
      Rails.application.config.action_controller.action_on_unpermitted_parameters = false
      raw_params       = build_unclean_params('page' => '3', 'keywords' => 'statistics', 'hax' => 'javascript:alert("boo!")')
      cleaned_params   = CleanedParams.new(raw_params)

      assert_equal({ 'page' => '3', 'keywords' => 'statistics' }, cleaned_params)
    end

    test "permitted scaler parameters passed in as an array are scrubbed" do
      raw_params       = build_unclean_params('page' => [], 'keywords' => 'statistics')
      cleaned_params   = CleanedParams.new(raw_params)

      assert_equal({ 'keywords' => 'statistics'}, cleaned_params)
    end

    test "permitted scaler parameters passed in as a hash are scrubbed" do
      raw_params       = build_unclean_params('page' => {"$acunetix"=>"1"}, 'keywords' => 'statistics')
      cleaned_params   = CleanedParams.new(raw_params)

      assert_equal({ 'keywords' => 'statistics'}, cleaned_params)
    end

    test "#unpermitted keys returns any param keys that are not permitted" do
      raw_params       = build_unclean_params('action' => 'show', 'page' => '3', 'stuff' => 'things', 'hax' => 'haha!')
      cleaned_params   = CleanedParams.new(raw_params)

      assert_same_elements ['stuff', 'hax'], cleaned_params.unpermitted_keys
    end

  private

    def build_unclean_params(param_hash)
      params = ActionController::Parameters.new(param_hash)
    end
  end
end
