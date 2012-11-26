# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'whitehall/uploader/heading_validator'

module Whitehall::Uploader
  class HeadingValidatorTest < ActiveSupport::TestCase
    test "duplicate fields are rejected" do
      validator = HeadingValidator.new
      assert_equal ['a_duplicate_field'], validator.duplicates(['a_duplicate_field', 'a_duplicate_field'])
      refute validator.valid?(['a_duplicate_field', 'a_duplicate_field'])
    end

    test "can specify required fields as array" do
      validator = HeadingValidator.new.required(['a_required_field'])
      refute validator.valid?([])
      assert_equal ['a_required_field'], validator.missing([])
      assert_equal [], validator.extra([])
    end

    test "can specify required fields as string" do
      validator = HeadingValidator.new.required('a_required_field')
      refute validator.valid?([])
      assert_equal ['a_required_field'], validator.missing([])
      assert_equal [], validator.extra([])
    end

    test "can specify optional fields as array" do
      validator = HeadingValidator.new.optional(['an_optional_field'])
      assert_equal [], validator.errors(['an_optional_field'])
      assert validator.valid?([]), validator.errors([]).join(", ")
      assert validator.valid?(['an_optional_field'])
      refute validator.valid?(['not_allowed'])
      assert_equal [], validator.missing([])
      assert_equal [], validator.extra(['an_optional_field'])
      assert_equal ['not_allowed'], validator.extra(['not_allowed'])
    end

    test "can match multiple fields using number pattern" do
      validator = HeadingValidator.new.multiple(['minister_#'])
      assert validator.valid?(['minister_1']), validator.errors(['minister_1']).join("")
      assert_equal [], validator.missing(['minister_1'])
      assert_equal [], validator.extra(['minister_1'])
      assert_equal [], validator.extra(['minister_1', 'minister_2', 'minister_3'])
      assert_equal ['foo'], validator.extra(['foo'])
    end

    test "can identify missing fields in a correlated field set" do
      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'])
      assert_equal [], validator.errors(%w{attachment_1 attachment_1_url})
      assert_equal ['attachment_1_url'], validator.missing(%w{attachment_1})
      refute validator.valid?(%w{attachment_1})
    end

    test "can constrain maximum multiplicity of multiple fields" do
      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'], 0..2)
      one_attachment = %w{attachment_1 attachment_1_url}
      two_attachments = one_attachment + %w{attachment_2 attachment_2_url}
      three_attachments = two_attachments + %w{attachment_3 attachment_3_url}
      assert_equal %w{attachment_3 attachment_3_url}, validator.extra(three_attachments)
      assert_equal %w{attachment_1 attachment_1_url}, validator.missing([])
      assert validator.valid?(one_attachment)
      assert validator.valid?(two_attachments)
      refute validator.valid?(three_attachments)
    end

    test "can constrain minimum multiplicity of multiple fields" do
      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'], 1..2)
      assert_equal ['attachment_1', 'attachment_1_url'], validator.missing([])
      refute validator.valid?([])
      assert validator.valid?(['attachment_1', 'attachment_1_url'])

      validator = HeadingValidator.new.multiple(['attachment_#', 'attachment_#_url'], 2..3)
      assert_equal ['attachment_2', 'attachment_2_url'], validator.missing(['attachment_1', 'attachment_1_url'])
    end

    test "can ignore fields" do
      validator = HeadingValidator.new.ignored("ignore_*")
      assert_equal [], validator.extra(['ignore_this'])
      assert_equal ['dont_ignore_this'], validator.extra(['dont_ignore_this'])
    end

  end
end
