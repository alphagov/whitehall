require "test_helper"

class NationApplicabilityValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = NationApplicabilityValidator.new({ attributes: %w[nation_applicability] })
  end

  class NationApplicabilityValidatorTestClass
    include ActiveModel::API
    attr_accessor :nation_applicability
  end

  test "is invalid when no value has been selected" do
    block_content = NationApplicabilityValidatorTestClass.new
    block_content.nation_applicability = nil

    @validator.validate(block_content)

    assert_includes block_content.errors[:nation_applicability], "- you must select whether this content applies to all UK nations or which nations it does not apply to"
  end

  test "is valid when 'applies to all UK nations' is selected" do
    block_content = NationApplicabilityValidatorTestClass.new
    block_content.nation_applicability = %w[all]

    @validator.validate(block_content)

    assert_empty block_content.errors[:nation_applicability]
  end

  test "is valid when one or more nations are excluded" do
    block_content = NationApplicabilityValidatorTestClass.new
    block_content.nation_applicability = %w[england wales]

    @validator.validate(block_content)

    assert_empty block_content.errors[:nation_applicability]
  end

  test "is invalid when 'all' is selected alongside specific nations" do
    block_content = NationApplicabilityValidatorTestClass.new
    block_content.nation_applicability = %w[all england]

    @validator.validate(block_content)

    assert_includes block_content.errors[:nation_applicability], "- you cannot select all UK nations and also exclude nations"
  end

  test "is invalid when it contains a value that is not a recognised nation" do
    block_content = NationApplicabilityValidatorTestClass.new
    block_content.nation_applicability = %w[not_a_nation]

    @validator.validate(block_content)

    assert_includes block_content.errors[:nation_applicability], "- contains an invalid nation"
  end
end
