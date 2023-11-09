require "test_helper"

module PublishingApi::CallForEvidencePresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :call_for_evidence, :update_type

    setup do
      create(:current_government)
      CallForEvidenceResponseFormData.any_instance.stubs(:auth_bypass_ids).returns(["auth bypass id"])
    end

    def presented_call_for_evidence
      PublishingApi::CallForEvidencePresenter.new(
        call_for_evidence,
        update_type:,
      )
    end

    def presented_content
      presented_call_for_evidence.content
    end

    def presented_links
      presented_call_for_evidence.links
    end

    def assert_attribute(attribute, value)
      assert_equal value, presented_content[attribute]
    end

    def assert_details_attribute(attribute, value)
      assert_equal value, presented_content[:details][attribute]
    end

    def assert_payload(builder, data: -> { presented_content })
      builder_double = builder.demodulize.underscore
      payload_double = { "#{builder_double}_key": "#{builder_double}_value" }

      builder
        .constantize
        .expects(:for)
        .at_least_once
        .with(call_for_evidence)
        .returns(payload_double)

      actual_data = data.call
      expected_data = actual_data.merge(payload_double)

      assert_equal expected_data, actual_data
    end

    def assert_details_payload(builder)
      assert_payload builder, data: -> { presented_content[:details] }
    end
  end

  class BasicCallForEvidenceTest < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence)
    end

    test "base" do
      attributes_double = {
        base_attribute_one: "base_attribute_one",
        base_attribute_two: "base_attribute_two",
        base_attribute_three: "base_attribute_three",
      }

      PublishingApi::BaseItemPresenter
        .expects(:new)
        .with(call_for_evidence, update_type: "major")
        .returns(stub(base_attributes: attributes_double))

      actual_content = presented_content
      expected_content = actual_content.merge(attributes_double)

      assert_equal actual_content, expected_content
    end

    test "base links" do
      expected_link_keys = %i[
        organisations
        parent
        topics
        government
      ]

      links_double = {
        link_one: "link_one",
        link_two: "link_two",
        link_three: "link_three",
      }

      PublishingApi::LinksPresenter
        .expects(:new)
        .with(call_for_evidence)
        .returns(
          mock("PublishingApi::LinksPresenter").tap do |m|
            m.expects(:extract)
              .with(expected_link_keys)
              .returns(links_double)
          end,
        )

      actual_links = presented_links
      expected_links = actual_links.merge(links_double)

      assert_equal actual_links, expected_links
    end

    test "edition links" do
      expected_links = {
        organisations: call_for_evidence.organisations.map(&:content_id),
        parent: [],
        topics: [],
      }

      assert_hash_includes presented_content[:links], expected_links
    end

    test "body details" do
      body_double = Object.new

      govspeak_renderer = mock("Whitehall::GovspeakRenderer")

      govspeak_renderer
        .expects(:govspeak_edition_to_html)
        .with(call_for_evidence)
        .returns(body_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::CallForEvidencePresenter::Documents.stubs(:for).returns({})
      PublishingApi::CallForEvidencePresenter::Outcome.stubs(:for).returns({})

      assert_details_attribute :body, body_double
    end

    test "content id" do
      assert_equal call_for_evidence.content_id, presented_call_for_evidence.content_id
    end

    test "description" do
      assert_attribute :description, call_for_evidence.summary
    end

    test "document type" do
      assert_attribute :document_type, "open_call_for_evidence"
    end

    test "emphasised organisations" do
      assert_details_attribute :emphasised_organisations,
                               call_for_evidence.lead_organisations.map(&:content_id)
    end

    test "first public at details" do
      assert_details_payload "PublishingApi::PayloadBuilder::FirstPublicAt"
    end

    test "political details" do
      assert_details_payload "PublishingApi::PayloadBuilder::PoliticalDetails"
    end

    test "public document path" do
      assert_payload "PublishingApi::PayloadBuilder::PublicDocumentPath"
    end

    test "rendering app" do
      assert_attribute :rendering_app, "government-frontend"
    end

    test "schema name" do
      assert_attribute :schema_name, "call_for_evidence"
    end

    test "auth bypass id" do
      assert_attribute :auth_bypass_ids, [call_for_evidence.auth_bypass_id]
    end

    test "tags" do
      assert_details_payload "PublishingApi::PayloadBuilder::TagDetails"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end

    test "it presents the base_path if locale is :en" do
      assert_equal "/government/calls-for-evidence/call-for-evidence-title", presented_content[:base_path]
    end

    test "it presents the base_path with locale if non-english" do
      with_locale("it") do
        assert_equal "/government/calls-for-evidence/call-for-evidence-title.it", presented_content[:base_path]
      end
    end

    test "it presents the default global process wide locale as the locale of the call for evidence" do
      assert_equal "en", presented_content[:locale]
    end

    test "it presents the selected global process wide locale as the locale of the call for evidence" do
      with_locale("it") do
        assert_equal "it", presented_content[:locale]
      end
    end
  end

  class UnopenedCallForEvidenceTest < TestCase
    setup do
      self.call_for_evidence = create(:unopened_call_for_evidence)
    end

    test "document type" do
      assert_attribute :document_type, "call_for_evidence"
    end
  end

  class OpenCallForEvidenceTest < TestCase
    setup do
      self.call_for_evidence = create(
        :open_call_for_evidence,
        closing_at: 1.day.from_now,
        opening_at: 1.day.ago,
      )
    end

    test "closing date" do
      assert_details_attribute :closing_date, 1.day.from_now
    end

    test "document type" do
      assert_attribute :document_type, "open_call_for_evidence"
    end

    test "opening date" do
      assert_details_attribute :opening_date, 1.day.ago
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class OpenCallForEvidenceWithParticipationTest < TestCase
    setup do
      response_form_data_attributes = attributes_for(
        :call_for_evidence_response_form_data,
      )

      response_form_attributes = attributes_for(
        :call_for_evidence_response_form,
        call_for_evidence_response_form_data_attributes: response_form_data_attributes,
      )

      participation = create(
        :call_for_evidence_participation,
        call_for_evidence_response_form_attributes: response_form_attributes,
        email: "postmaster@example.com",
        link_url: "http://www.example.com",
        postal_address: <<-ADDRESS.strip_heredoc.chop,
                        2 Home Farm Ln
                        Kirklington
                        Newark
                        NG22 8PE
                        UK
        ADDRESS
      )

      self.call_for_evidence = create(
        :open_call_for_evidence,
        call_for_evidence_participation: participation,
      )
    end

    test "document type" do
      assert_attribute :document_type, "open_call_for_evidence"
    end

    test "ways to respond" do
      Plek.any_instance.stubs(:asset_root).returns("https://asset-host.com")
      expected_id = CallForEvidenceResponseFormData.where(carrierwave_file: "two-pages.pdf").last.id
      expected_ways_to_respond = {
        attachment_url: "https://asset-host.com/government/uploads/system/uploads/call_for_evidence_response_form_data/file/#{expected_id}/two-pages.pdf",
        email: "postmaster@example.com",
        link_url: "http://www.example.com",
        postal_address: <<-ADDRESS.strip_heredoc.chop,
                        2 Home Farm Ln
                        Kirklington
                        Newark
                        NG22 8PE
                        UK
        ADDRESS
      }

      assert_details_attribute :ways_to_respond, expected_ways_to_respond
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class ClosedCallForEvidenceTest < TestCase
    setup do
      self.call_for_evidence = create("closed_call_for_evidence")
    end

    test "document type" do
      assert_attribute :document_type, "closed_call_for_evidence"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class ClosedCallForEvidenceWithOutcomeTest < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence_with_outcome_file_attachment)
    end

    test "document type" do
      assert_attribute :document_type, "call_for_evidence_outcome"
    end

    test "outcome detail" do
      outcome_detail_double = Object.new

      govspeak_renderer = mock("Whitehall::GovspeakRenderer")

      govspeak_renderer.stubs(:block_attachments)

      govspeak_renderer
        .expects(:govspeak_to_html)
        .with(call_for_evidence.outcome.summary)
        .returns(outcome_detail_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::CallForEvidencePresenter.any_instance.stubs(:body)
      PublishingApi::CallForEvidencePresenter::Documents.stubs(:for).returns({})

      assert_details_attribute :outcome_detail,
                               outcome_detail_double
    end

    test "outcome documents" do
      attachments_double = Object.new

      govspeak_renderer = mock("Whitehall::GovspeakRenderer")

      govspeak_renderer.stubs(:govspeak_to_html)

      govspeak_renderer
        .expects(:block_attachments)
        .with(
          call_for_evidence.outcome.attachments,
          call_for_evidence.outcome.alternative_format_contact_email,
        )
        .returns([attachments_double])
        .at_least_once

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer).at_least_once

      PublishingApi::CallForEvidencePresenter.any_instance.stubs(:body)
      PublishingApi::CallForEvidencePresenter::Documents.stubs(:for).returns({})

      assert_details_attribute :outcome_documents, [attachments_double]
      assert_details_attribute :outcome_attachments,
                               (call_for_evidence.outcome.attachments.map { |a| a.publishing_api_details[:id] })
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class CallForEvidenceWithAccessLimitation < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence)
    end

    test "access limited" do
      assert_payload "PublishingApi::PayloadBuilder::AccessLimitation"
    end
  end

  class CallForEvidenceWithFileAttachments < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence, :with_html_attachment)
    end

    test "documents" do
      attachments_double = Object.new

      govspeak_renderer = mock("Whitehall::GovspeakRenderer")

      govspeak_renderer
        .expects(:block_attachments)
        .with(
          call_for_evidence.attachments,
          call_for_evidence.alternative_format_contact_email,
        )
        .returns([attachments_double])
        .at_least_once

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer).at_least_once

      PublishingApi::CallForEvidencePresenter.any_instance.stubs(:body)

      assert_details_attribute :documents, [attachments_double]
      assert_details_attribute :featured_attachments,
                               (call_for_evidence.attachments.map { |a| a.publishing_api_details[:id] })
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class CallForEvidenceWithPublicTimestamp < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence_with_outcome)

      call_for_evidence.stubs(
        public_timestamp: Date.new(1999),
        updated_at: Date.new(2012),
      )
    end

    test "public updated at" do
      assert_attribute :public_updated_at,
                       "1999-01-01T00:00:00+00:00"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class CallForEvidenceWithoutPublicTimestamp < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence_with_outcome)

      call_for_evidence.stubs(
        public_timestamp: nil,
        updated_at: Date.new(2012),
      )
    end

    test "public updated at" do
      assert_attribute :public_updated_at,
                       "2012-01-01T00:00:00+00:00"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class CallForEvidenceHeldOnAnotherWebsite < TestCase
    setup do
      self.call_for_evidence = create(
        :open_call_for_evidence,
        external: true,
        external_url: "https://example.com/link/to/call_for_evidence",
      )
    end

    test "held on another website URL" do
      assert_details_attribute :held_on_another_website_url,
                               "https://example.com/link/to/call_for_evidence"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class CallForEvidenceWithNationalApplicability < TestCase
    setup do
      scotland_nation_inapplicability = create(
        :nation_inapplicability,
        nation: Nation.scotland,
        alternative_url: "http://scotland.com",
      )

      self.call_for_evidence = create(
        :call_for_evidence_with_excluded_nations,
        nation_inapplicabilities: [scotland_nation_inapplicability],
      )
    end

    test "national applicability" do
      assert_details_attribute :national_applicability,
                               england: {
                                 label: "England",
                                 applicable: true,
                               },
                               northern_ireland: {
                                 label: "Northern Ireland",
                                 applicable: true,
                               },
                               scotland: {
                                 label: "Scotland",
                                 applicable: false,
                                 alternative_url: "http://scotland.com",
                               },
                               wales: {
                                 label: "Wales",
                                 applicable: true,
                               }
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class CallForEvidenceWithChangeHistory < TestCase
    setup do
      self.call_for_evidence = create(:open_call_for_evidence)
    end

    test "change history" do
      expected_change_history = [
        {
          "public_timestamp" => "2011-11-09T11:11:11.000+00:00",
          "note" => "change-note",
        },
      ]

      assert_details_attribute :change_history, expected_change_history
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "call_for_evidence"
      assert_valid_against_links_schema({ links: presented_links }, "call_for_evidence")
    end
  end

  class CallForEvidenceWithMajorChange < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence, minor_change: false)
      self.update_type = "major"
    end

    test "update type" do
      assert_equal "major", presented_call_for_evidence.update_type
    end
  end

  class CallForEvidenceWithMinorChange < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence, minor_change: true)
    end

    test "update type" do
      assert_equal "minor", presented_call_for_evidence.update_type
    end
  end

  class CallForEvidenceWithoutMinorChange < TestCase
    setup do
      self.call_for_evidence = create(:call_for_evidence, minor_change: false)
    end

    test "update type" do
      assert_equal "major", presented_call_for_evidence.update_type
    end
  end

  class CallForEvidenceithMinisterialRoleAppointments < TestCase
    setup do
      self.call_for_evidence = create(
        :call_for_evidence,
        role_appointments: create_list(:ministerial_role_appointment, 2),
        topical_events: create_list(:topical_event, 2),
      )
    end

    test "people" do
      expected_content_ids = call_for_evidence
        .role_appointments
        .map(&:person)
        .map(&:content_id)

      assert expected_content_ids.present?
      assert_equal expected_content_ids, presented_links[:people]
    end

    test "roles" do
      expected_content_ids = call_for_evidence
        .role_appointments
        .map(&:role)
        .map(&:content_id)

      assert expected_content_ids.present?
      assert_equal expected_content_ids, presented_links[:roles]
    end

    test "topical events" do
      expected_content_ids = call_for_evidence
        .topical_events
        .map(&:content_id)

      assert expected_content_ids.present?
      assert_equal expected_content_ids, presented_links[:topical_events]
    end
  end
end
