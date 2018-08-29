require 'test_helper'

module PublishingApi::ConsultationPresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :consultation, :update_type

    setup do
      create(:current_government)
    end

    def presented_consultation
      PublishingApi::ConsultationPresenter.new(
        consultation,
        update_type: update_type,
      )
    end

    def presented_content
      presented_consultation.content
    end

    def presented_links
      presented_consultation.links
    end

    def assert_attribute(attribute, value)
      assert_equal value, presented_content[attribute]
    end

    def assert_details_attribute(attribute, value)
      assert_equal value, presented_content[:details][attribute]
    end

    def assert_payload(builder, data: -> { presented_content })
      builder_double = builder.demodulize.underscore
      payload_double = { :"#{builder_double}_key" => "#{builder_double}_value" }

      builder
        .constantize
        .expects(:for)
        .at_least_once
        .with(consultation)
        .returns(payload_double)

      actual_data = data.call
      expected_data = actual_data.merge(payload_double)

      assert_equal expected_data, actual_data
    end

    def assert_details_payload(builder)
      assert_payload builder, data: -> { presented_content[:details] }
    end
  end

  class BasicConsultationTest < TestCase
    setup do
      self.consultation = create(:consultation)
    end

    test 'base' do
      attributes_double = {
        base_attribute_one: 'base_attribute_one',
        base_attribute_two: 'base_attribute_two',
        base_attribute_three: 'base_attribute_three',
      }

      PublishingApi::BaseItemPresenter
        .expects(:new)
        .with(consultation, update_type: "major")
        .returns(stub(base_attributes: attributes_double))

      actual_content = presented_content
      expected_content = actual_content.merge(attributes_double)

      assert_equal actual_content, expected_content
    end

    test 'base links' do
      expected_link_keys = %i(
        organisations
        parent
        policy_areas
        related_policies
        topics
      )

      links_double = {
        link_one: 'link_one',
        link_two: 'link_two',
        link_three: 'link_three',
      }

      PublishingApi::LinksPresenter
        .expects(:new)
        .with(consultation)
        .returns(
          mock('PublishingApi::LinksPresenter') {
            expects(:extract)
              .with(expected_link_keys)
              .returns(links_double)
          }
        )

      actual_links = presented_links
      expected_links = actual_links.merge(links_double)

      assert_equal actual_links, expected_links
    end

    test 'edition links' do
      expected_links = {
        organisations: consultation.organisations.map(&:content_id),
        parent: [],
        policy_areas: consultation.topics.map(&:content_id),
        related_policies: [],
        topics: []
      }

      assert_hash_includes presented_content[:links], expected_links
    end

    test 'body details' do
      body_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer
        .expects(:govspeak_edition_to_html)
        .with(consultation)
        .returns(body_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::ConsultationPresenter::Documents.stubs(:for).returns({})
      PublishingApi::ConsultationPresenter::FinalOutcome.stubs(:for).returns({})
      PublishingApi::ConsultationPresenter::PublicFeedback.stubs(:for).returns({})

      assert_details_attribute :body, body_double
    end

    test 'content id' do
      assert_equal consultation.content_id, presented_consultation.content_id
    end

    test 'description' do
      assert_attribute :description, consultation.summary
    end

    test 'document type' do
      assert_attribute :document_type, 'open_consultation'
    end

    test 'emphasised organisations' do
      assert_details_attribute :emphasised_organisations,
                               consultation.lead_organisations.map(&:content_id)
    end

    test 'first public at details' do
      assert_details_payload 'PublishingApi::PayloadBuilder::FirstPublicAt'
    end

    test 'political details' do
      assert_details_payload 'PublishingApi::PayloadBuilder::PoliticalDetails'
    end

    test 'public document path' do
      assert_payload 'PublishingApi::PayloadBuilder::PublicDocumentPath'
    end

    test 'rendering app' do
      assert_attribute :rendering_app, 'government-frontend'
    end

    test 'schema name' do
      assert_attribute :schema_name, 'consultation'
    end

    test 'tags' do
      assert_details_payload 'PublishingApi::PayloadBuilder::TagDetails'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class UnopenedConsultationTest < TestCase
    setup do
      self.consultation = create(:unopened_consultation)
    end

    test 'document type' do
      assert_attribute :document_type, 'consultation'
    end
  end

  class OpenConsultationTest < TestCase
    setup do
      self.consultation = create(
        :open_consultation,
        closing_at: 1.day.from_now,
        opening_at: 1.day.ago,
      )
    end

    test 'closing date' do
      assert_details_attribute :closing_date, 1.day.from_now
    end

    test 'document type' do
      assert_attribute :document_type, 'open_consultation'
    end

    test 'opening date' do
      assert_details_attribute :opening_date, 1.day.ago
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class OpenConsultationWithParticipationTest < TestCase
    setup do
      response_form_data_attributes = attributes_for(
        :consultation_response_form_data
      )

      response_form_attributes = attributes_for(
        :consultation_response_form,
        consultation_response_form_data_attributes: response_form_data_attributes
      )

      participation = create(
        :consultation_participation,
        consultation_response_form_attributes: response_form_attributes,
        email: 'postmaster@example.com',
        link_url: 'http://www.example.com',
        postal_address: <<-ADDRESS.strip_heredoc.chop
                        2 Home Farm Ln
                        Kirklington
                        Newark
                        NG22 8PE
                        UK
        ADDRESS
      )

      self.consultation = create(:open_consultation,
                                 consultation_participation: participation)
    end

    test 'document type' do
      assert_attribute :document_type, 'open_consultation'
    end

    test 'ways to respond' do
      Plek.any_instance.stubs(:public_asset_host).returns('https://asset-host.com')
      expected_id = ConsultationResponseFormData.where(carrierwave_file: 'two-pages.pdf').last.id
      expected_ways_to_respond = {
        attachment_url: "https://asset-host.com/government/uploads/system/uploads/consultation_response_form_data/file/#{expected_id}/two-pages.pdf",
        email: 'postmaster@example.com',
        link_url: 'http://www.example.com',
        postal_address: <<-ADDRESS.strip_heredoc.chop
                        2 Home Farm Ln
                        Kirklington
                        Newark
                        NG22 8PE
                        UK
        ADDRESS
      }

      assert_details_attribute :ways_to_respond, expected_ways_to_respond
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ClosedConsultationTest < TestCase
    setup do
      self.consultation = create('closed_consultation')
    end

    test 'document type' do
      assert_attribute :document_type, 'closed_consultation'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ClosedConsultationWithFeedbackTest < TestCase
    setup do
      self.consultation = create(:closed_consultation)

      create(:consultation_public_feedback,
             :with_file_attachment,
             consultation: consultation,
             summary: 'Public feedback summary')
    end

    test 'document type' do
      assert_attribute :document_type, 'closed_consultation'
    end

    test 'public feedback detail' do
      public_feedback_detail_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer.stubs(:block_attachments)

      govspeak_renderer
        .expects(:govspeak_to_html)
        .with(consultation.public_feedback.summary)
        .returns(public_feedback_detail_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::ConsultationPresenter.any_instance.stubs(:body)
      PublishingApi::ConsultationPresenter::Documents.stubs(:for).returns({})
      PublishingApi::ConsultationPresenter::FinalOutcome.stubs(:for).returns({})

      assert_details_attribute :public_feedback_detail,
                               public_feedback_detail_double
    end

    test 'public feedback documents' do
      attachments_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer.stubs(:govspeak_to_html)

      govspeak_renderer
        .expects(:block_attachments)
        .with(
          consultation.public_feedback.attachments,
          consultation.public_feedback.alternative_format_contact_email,
          consultation.public_feedback.published_on,
        )
        .returns(attachments_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::ConsultationPresenter.any_instance.stubs(:body)
      PublishingApi::ConsultationPresenter::Documents.stubs(:for).returns({})
      PublishingApi::ConsultationPresenter::FinalOutcome.stubs(:for).returns({})

      assert_details_attribute :public_feedback_documents,
                               attachments_double
    end

    test 'public feedback publication date' do
      assert_details_attribute :public_feedback_publication_date,
                               '2011-11-11T00:00:00+00:00'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ClosedConsultationWithOutcomeTest < TestCase
    setup do
      self.consultation = create(:consultation_with_outcome_attachment)
    end

    test 'document type' do
      assert_attribute :document_type, 'consultation_outcome'
    end

    test 'final outcome detail' do
      final_outcome_detail_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer.stubs(:block_attachments)

      govspeak_renderer
        .expects(:govspeak_to_html)
        .with(consultation.outcome.summary)
        .returns(final_outcome_detail_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::ConsultationPresenter.any_instance.stubs(:body)
      PublishingApi::ConsultationPresenter::Documents.stubs(:for).returns({})
      PublishingApi::ConsultationPresenter::PublicFeedback.stubs(:for).returns({})

      assert_details_attribute :final_outcome_detail,
                               final_outcome_detail_double
    end

    test 'final outcome documents' do
      attachments_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer.stubs(:govspeak_to_html)

      govspeak_renderer
        .expects(:block_attachments)
        .with(
          consultation.outcome.attachments,
          consultation.outcome.alternative_format_contact_email,
        )
        .returns(attachments_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::ConsultationPresenter.any_instance.stubs(:body)
      PublishingApi::ConsultationPresenter::Documents.stubs(:for).returns({})
      PublishingApi::ConsultationPresenter::PublicFeedback.stubs(:for).returns({})

      assert_details_attribute :final_outcome_documents, attachments_double
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ConsultationWithAccessLimitation < TestCase
    setup do
      self.consultation = create(:consultation)
    end

    test 'access limited' do
      assert_payload 'PublishingApi::PayloadBuilder::AccessLimitation'
    end
  end

  class ConsultationWithFileAttachments < TestCase
    setup do
      self.consultation = create(:consultation, :with_html_attachment)
    end

    test 'documents' do
      attachments_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer
        .expects(:block_attachments)
        .with(
          consultation.attachments,
          consultation.alternative_format_contact_email,
        )
        .returns(attachments_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      PublishingApi::ConsultationPresenter.any_instance.stubs(:body)
      PublishingApi::ConsultationPresenter::FinalOutcome.stubs(:for).returns({})
      PublishingApi::ConsultationPresenter::PublicFeedback.stubs(:for).returns({})

      assert_details_attribute :documents, attachments_double
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ConsultationWithPublicTimestamp < TestCase
    setup do
      self.consultation = create(:consultation_with_outcome)

      consultation.stubs(public_timestamp: Date.new(1999),
                         updated_at: Date.new(2012))
    end

    test 'public updated at' do
      assert_attribute :public_updated_at,
                       '1999-01-01T00:00:00+00:00'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ConsultationWithoutPublicTimestamp < TestCase
    setup do
      self.consultation = create(:consultation_with_outcome)

      consultation.stubs(public_timestamp: nil,
                         updated_at: Date.new(2012))
    end

    test 'public updated at' do
      assert_attribute :public_updated_at,
                       '2012-01-01T00:00:00+00:00'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ConsultationHeldOnAnotherWebsite < TestCase
    setup do
      self.consultation = create(
        :open_consultation,
        external: true,
        external_url: 'https://example.com/link/to/consultation'
      )
    end

    test 'held on another website URL' do
      assert_details_attribute :held_on_another_website_url,
                               'https://example.com/link/to/consultation'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ConsultationWithNationalApplicability < TestCase
    setup do
      scotland_nation_inapplicability = create(
        :nation_inapplicability,
        nation: Nation.scotland,
        alternative_url: 'http://scotland.com'
      )

      self.consultation = create(
        :consultation,
        nation_inapplicabilities: [scotland_nation_inapplicability]
      )
    end

    test 'national applicability' do
      assert_details_attribute :national_applicability,
                               england: {
                                 label: 'England',
                                 applicable: true,
                               },
                               northern_ireland: {
                                 label: 'Northern Ireland',
                                 applicable: true,
                               },
                               scotland: {
                                 label: 'Scotland',
                                 applicable: false,
                                 alternative_url: 'http://scotland.com'
                               },
                               wales: {
                                 label: 'Wales',
                                 applicable: true,
                               }
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ConsultationWithChangeHistory < TestCase
    setup do
      self.consultation = create(:open_consultation)
    end

    test 'change history' do
      expected_change_history = [
        {
          'public_timestamp' => '2011-11-09T11:11:11.000+00:00',
          'note' => 'change-note',
        }
      ]

      assert_details_attribute :change_history, expected_change_history
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end

  class ConsultationWithMajorChange < TestCase
    setup do
      self.consultation = create(:consultation, minor_change: false)
      self.update_type = 'major'
    end

    test 'update type' do
      assert_equal 'major', presented_consultation.update_type
    end
  end

  class ConsultationWithMinorChange < TestCase
    setup do
      self.consultation = create(:consultation, minor_change: true)
    end

    test 'update type' do
      assert_equal 'minor', presented_consultation.update_type
    end
  end

  class ConsultationWithoutMinorChange < TestCase
    setup do
      self.consultation = create(:consultation, minor_change: false,)
    end

    test 'update type' do
      assert_equal 'major', presented_consultation.update_type
    end
  end

  class ConsultationWithMinisterialRoleAppointments < TestCase
    setup do
      self.consultation = create(
        :consultation,
        role_appointments: create_list(:ministerial_role_appointment, 2),
        topical_events: create_list(:topical_event, 2),
      )
    end

    test 'ministers' do
      expected_content_ids = consultation
        .role_appointments
        .map(&:person)
        .map(&:content_id)

      assert expected_content_ids.present?
      assert_equal expected_content_ids, presented_links[:ministers]
    end

    test "people" do
      expected_content_ids = consultation
        .role_appointments
        .map(&:person)
        .map(&:content_id)

      assert expected_content_ids.present?
      assert_equal expected_content_ids, presented_links[:people]
    end

    test "roles" do
      expected_content_ids = consultation
        .role_appointments
        .map(&:role)
        .map(&:content_id)

      assert expected_content_ids.present?
      assert_equal expected_content_ids, presented_links[:roles]
    end

    test "topical events" do
      expected_content_ids = consultation
        .topical_events
        .map(&:content_id)

      assert expected_content_ids.present?
      assert_equal expected_content_ids, presented_links[:topical_events]
    end
  end
end
