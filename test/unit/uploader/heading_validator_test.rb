# encoding: UTF-8
require 'fast_test_helper'
require 'whitehall/uploader/heading_validator'

module Whitehall::Uploader
  class HeadingValidatorTest < ActiveSupport::TestCase
    test "duplicate fields are rejected" do
      validator = HeadingValidator.new
      assert_equal ['a_duplicate_field'], validator.validate(%w(a_duplicate_field a_duplicate_field)).duplicates
      refute validator.valid?(%w(a_duplicate_field a_duplicate_field))
    end

    test "can specify required fields as array" do
      validator = HeadingValidator.new.required(['a_required_field'])
      refute validator.valid?([])
      assert_equal ['a_required_field'], validator.validate([]).missing
      assert_equal [], validator.validate([]).extra
    end

    test "can specify required fields as string" do
      validator = HeadingValidator.new.required('a_required_field')
      refute validator.valid?([])
      assert_equal ['a_required_field'], validator.validate([]).missing
      assert_equal [], validator.validate([]).extra
    end

    test "required fields are case insensitive" do
      validator = HeadingValidator.new.required(%w(a_required_field ANOTHER_REQUIRED_FIELD))
      assert_equal [], validator.validate(%w(a_required_FIELD another_required_field)).missing
    end

    test "can specify optional fields as array" do
      validator = HeadingValidator.new.optional(['an_optional_field'])
      assert_equal [], validator.errors(['an_optional_field'])
      assert validator.valid?([]), validator.errors([]).join(", ")
      assert validator.valid?(['an_optional_field'])
      refute validator.valid?(['not_allowed'])
      assert_equal [], validator.validate([]).missing
      assert_equal [], validator.validate(['an_optional_field']).extra
      assert_equal ['not_allowed'], validator.validate(['not_allowed']).extra
    end

    test "can match multiple fields using number pattern" do
      validator = HeadingValidator.new.multiple(['minister_#'])
      assert validator.valid?(['minister_1']), validator.errors(['minister_1']).join("")
      assert_equal [], validator.validate(['minister_1']).missing
      assert_equal [], validator.validate(['minister_1']).extra
      assert_equal [], validator.validate(%w(minister_1 minister_2 minister_3)).extra
      assert_equal ['foo'], validator.validate(['foo']).extra
    end

    test "can identify missing fields in a correlated field set" do
      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'])
      assert_equal [], validator.errors(%w{attachment_1 attachment_1_url})
      assert_equal ['attachment_1_url'], validator.validate(%w{attachment_1}).missing
      refute validator.valid?(%w{attachment_1})
    end

    test "can constrain maximum multiplicity of multiple fields" do
      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'], 0..2)
      no_attachments = %w{}
      one_attachment = %w{attachment_1 attachment_1_url}
      two_attachments = one_attachment + %w{attachment_2 attachment_2_url}
      three_attachments = two_attachments + %w{attachment_3 attachment_3_url}
      assert_equal %w{}, validator.validate(no_attachments).missing
      assert_equal %w{attachment_3 attachment_3_url}, validator.validate(three_attachments).extra
      assert validator.valid?(no_attachments)
      assert validator.valid?(one_attachment)
      assert validator.valid?(two_attachments)
      refute validator.valid?(three_attachments)
    end

    test "can constrain minimum multiplicity of multiple fields" do
      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'], 1..2)
      assert_equal %w(attachment_1 attachment_1_url), validator.validate([]).missing
      refute validator.valid?([])
      assert validator.valid?(%w(attachment_1 attachment_1_url))

      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'], 2..3)
      assert_equal %w(attachment_2 attachment_2_url), validator.validate(%w(attachment_1 attachment_1_url)).missing
    end

    test "can ignore fields" do
      validator = HeadingValidator.new.ignored("ignore_*")
      assert_equal [], validator.validate(['ignore_this']).extra
      assert_equal ['dont_ignore_this'], validator.validate(['dont_ignore_this']).extra
    end

    test "translatable fields are ignored if locale is not specified" do
      validator = HeadingValidator.new.required(%w(a_required_field another_required_field)).translatable('a_required_field')
      assert_equal [], validator.errors(%w(a_required_field another_required_field))
    end

    test "required translatable fields and translation_url are required when locale is present" do
      validator = HeadingValidator.new.required(%w(required also_required)).translatable('required')

      assert validator.valid?(%w(required also_required))
      assert_equal %w(translation_url required_translation), validator.validate(%w(required also_required locale)).missing
      assert_equal %w(required_translation), validator.validate(%w(required also_required locale translation_url)).missing
      assert validator.valid?(%w(required also_required locale translation_url required_translation))
    end

    test "rogue translatable fields are flaggeed as extra" do
      validator = HeadingValidator.new.required(%w(required and_again)).translatable('required')

      refute validator.valid?(%w(required and_again locale and_again_translation))
      assert_equal ['and_again_translation'], validator.validate(%w(required and_again locale translation_url and_again_translation)).extra
      assert_equal [], validator.validate(%w(required and_again locale translation_url required_translation required_translation)).extra
    end

    test "optional translatable fields are optional" do
      validator = HeadingValidator.new.required('required').optional('optional').translatable(%w(required optional))
      assert validator.valid?(%w(required))
      assert validator.valid?(%w(required locale translation_url required_translation))
      assert validator.valid?(%w(required locale translation_url required_translation optional_translation))
    end
  end
end
