require "test_helper"

class FactoriesTest < ActiveSupport::TestCase
  FactoryGirl.factories.each do |factory|
    test "should be valid when #{factory.name} is built from the factory" do
      model_instance = build(factory.name)
      assert model_instance.valid?, model_instance.errors.full_messages.to_sentence
    end
  end
end
