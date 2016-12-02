require 'test_helper'

module PublishingApi::ConsultationPresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :consultation

    def presented_content
      PublishingApi::ConsultationPresenter.new(consultation).content
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
      create(
        :current_government,
        name: 'The Current Government',
        slug: 'the-current-government',
      )

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
        .with(consultation)
        .returns(stub(base_attributes: attributes_double))

      actual_content = presented_content
      expected_content = actual_content.merge(attributes_double)

      assert_equal actual_content, expected_content
    end

    test 'body details' do
      body_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer
        .expects(:govspeak_edition_to_html)
        .with(consultation)
        .returns(body_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      assert_details_attribute :body, body_double
    end

    test 'document type' do
      assert_attribute :document_type, 'consultation'
    end

    test 'political details' do
      assert_details_payload 'PublishingApi::PayloadBuilder::PoliticalDetails'
    end

    test 'public document path' do
      assert_payload 'PublishingApi::PayloadBuilder::PublicDocumentPath'
    end

    test 'rendering app' do
      assert_attribute :rendering_app, 'whitehall-frontend'
    end

    test 'schema name' do
      assert_attribute :schema_name, 'consultation'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'consultation'
    end
  end
end
