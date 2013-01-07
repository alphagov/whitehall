# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require File.expand_path("../../../fast_test_helper", __FILE__)
require 'whitehall/uploader/consultation_row'

module Whitehall::Uploader
  class ConsultationRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation')
    end

    def consultation_row(data)
      ConsultationRow.new(data, 1, @attachment_cache, @default_organisation)
    end

    def consultation_row_with_keys(keys)
      data = Hash[keys.zip(1.upto(keys.size))]
      consultation_row(data)
    end

    def basic_headings
      %w{
        old_url title summary body opening_date closing_date
        policy_1 policy_2 policy_3 policy_4
        organisation consultation_ISBN consultation_URN
        response_date response_summary
      }
    end

    test "validates row headings" do
      keys = basic_headings + %w{
        response_1_url response_1_title response_1_ISBN
        attachment_1_url attachment_1_title
      }
      assert_equal [], ConsultationRow.heading_validation_errors(keys)
    end

    test "validation reports missing row headings" do
      keys = basic_headings - ['title']
      assert_equal ["missing fields: 'title'"], ConsultationRow.heading_validation_errors(keys)
    end

    test "validation reports extra row headings" do
      keys = basic_headings + ['extra_stuff']
      assert_equal ["unexpected fields: 'extra_stuff'"], ConsultationRow.heading_validation_errors(keys)
    end

    test "validation accepts a complete set of response headings" do
      keys = basic_headings + %w{response_1_url response_1_title response_1_ISBN}
      assert_equal [], ConsultationRow.heading_validation_errors(keys)
    end

    test "validation accepts a complete set of attachment headings" do
      keys = basic_headings + %w{attachment_1_url attachment_1_title}
      assert_equal [], ConsultationRow.heading_validation_errors(keys)
    end

    test "validation complains of missing attachment headings" do
      keys = basic_headings + %w{attachment_1_title}
      assert_equal [
        "missing fields: 'attachment_1_url'",
        ], ConsultationRow.heading_validation_errors(keys)
    end

    test "validation complains of missing response headings" do
      keys = basic_headings + %w{response_1_title response_1_ISBN}
      assert_equal [
        "missing fields: 'response_1_url'",
        ], ConsultationRow.heading_validation_errors(keys)
    end

    test "takes title from the title column" do
      row = consultation_row("title" => "a-title")
      assert_equal "a-title", row.title
    end

    test "takes summary from the summary column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.stubs(:parse).with("relative links", "url").returns("absolute links")
      row = consultation_row("summary" => "relative links")
      row.stubs(:organisation).returns(stub("organisation", url: "url"))
      assert_equal "absolute links", row.summary
    end

    test "takes legacy url from the old_url column" do
      row = consultation_row("old_url" => "http://example.com/old-url")
      assert_equal "http://example.com/old-url", row.legacy_url
    end

    test "takes body from the 'body' column, converting relative links to absolute" do
      Parsers::RelativeToAbsoluteLinks.stubs(:parse).with("relative links", "url").returns("absolute links")
      row = consultation_row("body" => "relative links")
      row.stubs(:organisation).returns(stub("organisation", url: "url"))
      assert_equal "absolute links", row.body
    end

    test "takes opening on from the 'opening_date' column" do
      Parsers::DateParser.stubs(:parse).with("opening-on-date", anything, anything).returns("date-object")
      row = consultation_row("opening_date" => "opening-on-date")
      assert_equal "date-object", row.opening_on
    end

    test "takes closing on from the 'closing_date' column" do
      Parsers::DateParser.stubs(:parse).with("closing-on-date", anything, anything).returns("date-object")
      row = consultation_row("closing_date" => "closing-on-date")
      assert_equal "date-object", row.closing_on
    end

    test "finds an organisation using the organisation finder" do
      organisation = stub("Organisation")
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything, @default_organisation).returns([organisation])
      row = consultation_row("organisation" => "name or slug")
      assert_equal organisation, row.organisation
    end

    test "takes organisations as an array containing the found organisation" do
      row = consultation_row({})
      row.stubs(:organisation).returns(:organisation)
      assert_equal [:organisation], row.organisations
    end

    test "generates lead_edition_organisations by asking the edition organisation builder to build a lead with each found organisation" do
      row = consultation_row({})
      o = stub(:organisation)
      row.stubs(:organisations).returns([o])
      leo = stub(:lead_edition_organisation)
      Builders::EditionOrganisationBuilder.stubs(:build_lead).with(o, 1).returns(leo)
      assert_equal [leo], row.lead_edition_organisations
    end

    test "finds related policies using the policy finder" do
      policies = 5.times.map { stub('policy') }
      Finders::PoliciesFinder.stubs(:find).with("first", "second", "third", "fourth", anything, anything).returns(policies)
      row = consultation_row("policy_1" => "first", "policy_2" => "second", "policy_3" => "third", "policy_4" => "fourth")
      assert_equal policies, row.related_policies
    end

    test "builds up to 50 attachments from columns attachment_1_title, attachment_1_url..." do
      attachments = (1..50).map {|i| stub_everything("attachment-#{i}") }

      attributes = (1..50).each.with_object({}) do |i, hash|
        url = "http://example.com/attachment-#{i}.pdf"
        title = "title #{i}"
        hash["attachment_#{i}_title"] = title
        hash["attachment_#{i}_url"] = url
        Builders::AttachmentBuilder.stubs(:build).with({title: title}, url, @attachment_cache, anything, anything).returns(attachments[i - 1])
      end

      row = consultation_row(attributes)

      assert_equal attachments.first, row.attachments.first
      assert_equal attachments.last, row.attachments.last
    end

    test "sets isbn and urn on first attachment with values in consultation_ISBN and consultation_URN columns" do
      attachment = stub("attachment")
      attachment.expects(:unique_reference=).with("unique-reference-number")
      attachment.expects(:isbn=).with("isbn")

      Builders::AttachmentBuilder.stubs(:build).with({title: "title"}, "url", @attachment_cache, anything, anything).returns(attachment)

      row = consultation_row("attachment_1_title" => "title", "attachment_1_url" => "url", "consultation_urn" => "unique-reference-number", "consultation_isbn" => "isbn")

      row.attachments
    end

    test "builds a response from the whole row" do
      row_attributes = {}
      response = stub('response')
      response_builder = stub('response_builder', build: response)
      ConsultationRow::ResponseBuilder.stubs(:new).with(row_attributes, 1, @attachment_cache, anything).returns(response_builder)
      row = consultation_row(row_attributes)
      assert_equal response, row.response
    end

    test "supplies an attribute list for the new consultation record" do
      row = consultation_row({})
      attribute_keys = [:title, :summary, :body, :opening_on, :closing_on, :lead_edition_organisations, :related_policies, :attachments, :alternative_format_provider, :response]
      attribute_keys.each do |key|
        row.stubs(key).returns(key.to_s)
      end
      expected_attributes = attribute_keys.each.with_object({}) {|key, hash| hash[key] = key.to_s }
      assert_equal expected_attributes, row.attributes
    end
  end

  class ConsultationRow::ResponseBuilderTest < ActiveSupport::TestCase
    def response_builder(data)
      ConsultationRow::ResponseBuilder.new(data, 1, @attachment_cache, Logger.new($stdout), @response_class)
    end

    setup do
      @response_class = stub('response-class')
      @attachment_cache = stub('attachment cache')
    end

    test "takes summary from the 'response_summary' column" do
      builder = response_builder("response_summary" => "a-response-summary")
      assert_equal "a-response-summary", builder.summary
    end

    test "takes published_on from the 'response_date' column" do
      Parsers::DateParser.stubs(:parse).with("response-date", anything, anything).returns("date-object")

      builder = response_builder("response_date" => "response-date")
      assert_equal "date-object", builder.published_on
    end

    test "builds up to 10 attachments from columns response_1_title, response_1_url..." do
      attachments = (1..10).map {|i| stub_everything("attachment-#{i}") }

      attributes = (1..10).each.with_object({}) do |i, hash|
        url = "http://example.com/attachment-#{i}.pdf"
        title = "title #{i}"
        hash["response_#{i}_title"] = title
        hash["response_#{i}_url"] = url
        Builders::AttachmentBuilder.stubs(:build).with({title: title}, url, @attachment_cache, anything, anything).returns(attachments[i - 1])
      end

      builder = response_builder(attributes)

      assert_equal attachments.first, builder.attachments.first
      assert_equal attachments.last, builder.attachments.last
    end

    test "sets isbn on attachments from response_<n>_ISBN column if present" do
      attachment = stub("attachment")
      attachment.expects(:isbn=).with("isbn")

      Builders::AttachmentBuilder.stubs(:build).with({title: "title"}, "url", @attachment_cache, anything, anything).returns(attachment)

      builder = response_builder("response_1_title" => "title", "response_1_url" => "url", "response_1_isbn" => "isbn")

      builder.attachments
    end

    test "builds response with date, summary and attachments if response data found" do
      builder = response_builder({})
      attribute_keys = [:published_on, :summary, :attachments]
      attribute_keys.each do |key|
        builder.stubs(key).returns(key.to_s)
      end
      expected_attributes = attribute_keys.each.with_object({}) {|key, hash| hash[key] = key.to_s }
      response = stub('response')
      @response_class.stubs(:new).with(expected_attributes).returns(response)
      assert_equal response, builder.build
    end

    test "builds nothing if no response data found" do
      builder = response_builder({})
      assert_nil builder.build
    end
  end
end
