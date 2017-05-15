require 'test_helper'

module PublishingApi::CorporateInformationPagePresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :corporate_information_page, :update_type

    def presented_corporate_information_page
      PublishingApi::CorporateInformationPagePresenter.new(
        corporate_information_page,
        update_type: update_type,
      )
    end

    def presented_content
      presented_corporate_information_page.content
    end

    def presented_links
      presented_corporate_information_page.links
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
        .with(corporate_information_page)
        .returns(payload_double)

      actual_data = data.call
      expected_data = actual_data.merge(payload_double)

      assert_equal expected_data, actual_data
    end

    def assert_details_payload(builder)
      assert_payload builder, data: -> { presented_content[:details] }
    end

    def assert_links(key, value)
      assert_equal value.sort, presented_links[key].sort
    end

    def refute_details_attribute(attribute)
      refute presented_content[:details].key?(attribute)
    end
  end

  class BasicCorporateInformationPageTest < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page)
    end

    test 'base' do
      attributes_double = {
        base_attribute_one: 'base_attribute_one',
        base_attribute_two: 'base_attribute_two',
        base_attribute_three: 'base_attribute_three',
      }

      PublishingApi::BaseItemPresenter
        .expects(:new)
        .with(corporate_information_page)
        .returns(stub(base_attributes: attributes_double))

      actual_content = presented_content
      expected_content = actual_content.merge(attributes_double)

      assert_equal actual_content, expected_content
    end

    test 'base links' do
      expected_link_keys = %i(
        organisations
        parent
      )

      links_double = {
        link_one: 'link_one',
        link_two: 'link_two',
        link_three: 'link_three',
      }

      PublishingApi::LinksPresenter
        .expects(:new)
        .with(corporate_information_page)
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


    test 'body details' do
      body_double = Object.new

      govspeak_renderer = mock('Whitehall::GovspeakRenderer')

      govspeak_renderer
        .expects(:govspeak_edition_to_html)
        .with(corporate_information_page)
        .returns(body_double)

      Whitehall::GovspeakRenderer.expects(:new).returns(govspeak_renderer)

      assert_details_attribute :body, body_double
    end

    test 'corporate information groups' do
      refute_details_attribute :corporate_information_groups
    end

    test 'description' do
      assert_attribute :description, corporate_information_page.summary
    end

    test 'document type' do
      assert_attribute :document_type, 'publication_scheme'
    end

    test 'links' do
      expected_link_keys = %i(
        organisations
        parent
      )

      links_double = {
        link_one: 'link_one',
        link_two: 'link_two',
        link_three: 'link_three',
      }

      PublishingApi::LinksPresenter
        .stubs(:new)
        .with(corporate_information_page)
        .returns(
          mock('PublishingApi::LinksPresenter') {
            stubs(:extract)
              .with(expected_link_keys)
              .returns(links_double)
          }
        )

      actual_links = presented_links
      expected_links = actual_links.merge(links_double)

      assert_attribute :links, expected_links
    end

    test 'organisation details' do
      organisation = create(:organisation, content_id: '7bcea45b-57b1-4200-b35f-29d8324e9a68')

      corporate_information_page
        .stubs(owning_organisation: organisation)

      assert_details_attribute :organisation, '7bcea45b-57b1-4200-b35f-29d8324e9a68'
    end

    test 'public document path' do
      assert_payload 'PublishingApi::PayloadBuilder::PublicDocumentPath'
    end

    test 'rendering app' do
      assert_attribute :rendering_app, 'government-frontend'
    end

    test 'schema name' do
      assert_attribute :schema_name, 'corporate_information_page'
    end

    test 'tags' do
      assert_details_payload 'PublishingApi::PayloadBuilder::TagDetails'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'corporate_information_page'
    end
  end

  class AboutCorporateInformationPage < TestCase
    setup do
      organisation = create(
        :organisation,
        organisation_chart_url: 'https://www.example.com/path/to/org/chart',
      )

      self.corporate_information_page =
        create(:about_corporate_information_page, organisation: organisation)

      @about_our_services_corporate_information_page =
        create(:about_our_services_corporate_information_page,
               organisation: organisation)

      @complaints_procedure_corporate_information_page =
        create(:complaints_procedure_corporate_information_page,
               organisation: organisation)

      @our_energy_use_corporate_information_page =
        create(:our_energy_use_corporate_information_page,
               organisation: organisation)

      @personal_information_charter_corporate_information_page =
        create(:personal_information_charter_corporate_information_page,
               organisation: organisation)

      @procurement_corporate_information_page =
        create(:procurement_corporate_information_page,
               organisation: organisation)

      @publication_scheme_corporate_information_page =
        create(:publication_scheme_corporate_information_page,
               organisation: organisation)

      @recruitment_corporate_information_page =
        create(:recruitment_corporate_information_page,
               organisation: organisation)

      @social_media_use_information_page =
        create(:social_media_use_corporate_information_page,
               organisation: organisation)

      @welsh_language_scheme_corporate_information_page =
        create(:welsh_language_scheme_corporate_information_page,
               organisation: organisation)

      create_list(:published_publication, 2, :corporate,
                  organisations: [organisation])

      create_list(:published_publication, 2, :transparency_data,
                  organisations: [organisation])
    end

    test 'corporate information groups' do
      organisation_chart = {
        title: 'Our organisation chart',
        url: corporate_information_page.organisation.organisation_chart_url,
      }

      jobs = [
        @procurement_corporate_information_page.content_id,
        @recruitment_corporate_information_page.content_id,
        {
          title: 'Jobs',
          url: corporate_information_page.organisation.jobs_url,
        },
      ]

      our_information = [
        @complaints_procedure_corporate_information_page.content_id,
        @our_energy_use_corporate_information_page.content_id,
      ]

      corporate_reports_publications_filter = {
        title: 'Corporate reports',
        path: '/government/publications?' +
          "departments%5B%5D=#{corporate_information_page.organisation.slug}&" +
          'publication_type=corporate-reports',
      }

      transparency_data_publications_filter = {
        title: 'Transparency data',
        path: '/government/publications?' +
          "departments%5B%5D=#{corporate_information_page.organisation.slug}&" +
          'publication_type=transparency-data',
      }

      expected_groups = [
        {
          name: 'Access our information',
          contents: [].tap { |contents|
            contents.push(organisation_chart)
            contents.push(*our_information)
            contents.push(corporate_reports_publications_filter)
            contents.push(transparency_data_publications_filter)
          },
        },
        {
          name: 'Jobs and contracts',
          contents: [].tap { |contents|
            contents.push(*jobs)
          },
        }
      ]

      assert_details_attribute :corporate_information_groups, expected_groups
    end

    test 'corporate information page links' do
      expected_content_ids = [
        @about_our_services_corporate_information_page.content_id,
        @complaints_procedure_corporate_information_page.content_id,
        @our_energy_use_corporate_information_page.content_id,
        @personal_information_charter_corporate_information_page.content_id,
        @procurement_corporate_information_page.content_id,
        @publication_scheme_corporate_information_page.content_id,
        @recruitment_corporate_information_page.content_id,
        @social_media_use_information_page.content_id,
        @welsh_language_scheme_corporate_information_page.content_id,
      ]

      assert_links :corporate_information_pages, expected_content_ids
    end

    test 'document type' do
      assert_attribute :document_type, 'about'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'corporate_information_page'
    end
  end

  class ComplaintsProcedureCorporateInformationPage < TestCase
    setup do
      self.corporate_information_page =
        create(:complaints_procedure_corporate_information_page)
    end

    test 'document type' do
      assert_attribute :document_type, 'complaints_procedure'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'corporate_information_page'
    end
  end

  class CorporateInformationPageWithMajorChange < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page,
                                               minor_change: false)
      self.update_type = 'major'
    end

    test 'update type' do
      assert_equal 'major', presented_corporate_information_page.update_type
    end
  end

  class CorporateInformationPageWithMinorChange < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page,
                                               minor_change: true)
    end

    test 'update type' do
      assert_equal 'minor', presented_corporate_information_page.update_type
    end
  end

  class CorporateInformationPageWithoutMinorChange < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page,
                                               minor_change: false)
    end

    test 'update type' do
      assert_equal 'major', presented_corporate_information_page.update_type
    end
  end

  class CorporateInformationPageWithPublicTimestamp < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page)

      corporate_information_page.stubs(public_timestamp: Date.new(1999),
                                       updated_at: Date.new(2012))
    end

    test 'public updated at' do
      assert_attribute :public_updated_at,
                       '1999-01-01T00:00:00+00:00'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'corporate_information_page'
    end
  end

  class CorporateInformationPageWithoutPublicTimestamp < TestCase
    setup do
      self.corporate_information_page = create(:corporate_information_page)

      corporate_information_page.stubs(public_timestamp: nil,
                                       updated_at: Date.new(2012))
    end

    test 'public updated at' do
      assert_attribute :public_updated_at,
                       '2012-01-01T00:00:00+00:00'
    end

    test 'validity' do
      assert_valid_against_schema presented_content, 'corporate_information_page'
    end
  end
end
