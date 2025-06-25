require "test_helper"

class ParamsPreprocessorClass
  include ParamsPreprocessor

  attr_reader :params

  def initialize(params)
    @params = params
  end
end

class ContentBlockManager::ContentBlock::ParamsPreprocessorClassTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:params) { { object_type:, "something" => "else" } }

  let(:object) { ParamsPreprocessorClass.new(params) }

  describe "when object type is `telephones`" do
    let(:object_type) { "telephones" }

    it "should call the TelephonePreprocessor" do
      processed_params = stub(:processed_params)
      preprocessor = stub(:preprocessor, processed_params:)

      ParamsPreprocessors::TelephonePreprocessor.expects(:new)
                                                .with(params)
                                                .returns(preprocessor)

      assert_equal object.processed_params, processed_params
    end
  end
end
