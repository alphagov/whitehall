# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'whitehall/uploader/heading_validator'

module Whitehall::Uploader
  class HeadingValidatorTest < ActiveSupport::TestCase
    test "duplicate fields are rejected" do
      validator = HeadingValidator.new
      assert_equal ['a_duplicate_field'], validator.validate(['a_duplicate_field', 'a_duplicate_field']).duplicates
      refute validator.valid?(['a_duplicate_field', 'a_duplicate_field'])
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
      validator = HeadingValidator.new.required(['a_required_field', 'ANOTHER_REQUIRED_FIELD'])
      assert_equal [], validator.validate(['a_required_FIELD', 'another_required_field']).missing
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
      assert_equal [], validator.validate(['minister_1', 'minister_2', 'minister_3']).extra
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
      assert_equal ['attachment_1', 'attachment_1_url'], validator.validate([]).missing
      refute validator.valid?([])
      assert validator.valid?(['attachment_1', 'attachment_1_url'])

      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'], 2..3)
      assert_equal ['attachment_2', 'attachment_2_url'], validator.validate(['attachment_1', 'attachment_1_url']).missing
    end

    test "can ignore fields" do
      validator = HeadingValidator.new.ignored("ignore_*")
      assert_equal [], validator.validate(['ignore_this']).extra
      assert_equal ['dont_ignore_this'], validator.validate(['dont_ignore_this']).extra
    end

  end
end
