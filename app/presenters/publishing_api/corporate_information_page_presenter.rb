module PublishingApi
  class CorporateInformationPagePresenter
    extend Forwardable
    include UpdateTypeHelper

    SCHEMA_NAME = 'corporate_information_page'.freeze

    attr_reader :update_type

    def initialize(corporate_information_page, update_type: nil)
      self.corporate_information_page = corporate_information_page
      self.update_type =
        update_type || default_update_type(corporate_information_page)
    end

    def_delegator :corporate_information_page, :content_id

    def content
      BaseItemPresenter
        .new(corporate_information_page, update_type: update_type)
        .base_attributes
        .merge(PayloadBuilder::PublicDocumentPath.for(corporate_information_page))
        .merge(
          description: corporate_information_page.summary,
          details: details,
          document_type: display_type_key,
          public_updated_at: public_updated_at,
          rendering_app: corporate_information_page.rendering_app,
          schema_name: SCHEMA_NAME,
          links: links,
        )
    end

    def links
      links_presenter.extract(
        %i(
          organisations
          parent
        )
      ).merge(CorporateInformationPages.for(corporate_information_page))
    end

  private

    attr_accessor :corporate_information_page
    attr_writer :update_type

    def_delegator :corporate_information_page, :display_type_key

    def base_details
      {
        body: body,
      }
    end

    def body
      Whitehall::GovspeakRenderer
        .new
        .govspeak_edition_to_html(corporate_information_page)
    end

    def details
      base_details
        .merge(CorporateInformationGroups.for(corporate_information_page))
        .merge(Organisation.for(corporate_information_page))
        .merge(PayloadBuilder::TagDetails.for(corporate_information_page))
    end

    def links_presenter
      @links_presenter ||= LinksPresenter.new(corporate_information_page)
    end

    def public_updated_at
      public_updated_at = corporate_information_page.public_timestamp ||
        corporate_information_page.updated_at

      public_updated_at = if public_updated_at.respond_to?(:to_datetime)
                            public_updated_at.to_datetime
                          end

      public_updated_at.rfc3339
    end

    class CorporateInformationGroups
      extend Forwardable

      def self.for(corporate_information_page)
        new(corporate_information_page).call
      end

      def initialize(corporate_information_page,
                     context = ActionController::Base,
                     url_maker = Whitehall.url_maker)
        self.context = context
        self.corporate_information_page = corporate_information_page
        self.url_maker = url_maker
      end

      def call
        return {} unless corporate_information_page.about_page? &&
            organisation_has_any_transparency_pages?

        {
          corporate_information_groups: corporate_information_groups
            .reject { |group| group[:contents].empty? },
        }
      end

    private

      attr_accessor :context, :corporate_information_page, :url_maker

      def_delegator :context, :helpers
      def_delegator :corporate_information_page, :owning_organisation, :organisation

      def corporate_information_groups
        [].tap do |groups|
          groups << {
            name: translation_for_group(:access_our_info),
            contents: contents_for_access_our_info.compact,
          }

          unless organisation.court_or_hmcts_tribunal?
            groups << {
              name: translation_for_group(:jobs_and_contacts),
              contents: contents_for_jobs_and_contacts.compact,
            }
          end
        end
      end

      def contents_for_access_our_info
        [].tap do |contents|
          contents.push(payload_for_organisation_chart)
          contents.push(*page_content_ids_by_menu_heading(:our_information))
          contents.push(payload_for_corporate_reports)
          contents.push(payload_for_transparency_data)
        end
      end

      def contents_for_jobs_and_contacts
        [].tap do |contents|
          contents.push(*page_content_ids_by_menu_heading(:jobs_and_contracts))
          contents.push(payload_for_jobs)
        end
      end

      def organisation_has_any_transparency_pages?
        return unless organisation.present?

        organisation_has_freedom_of_information_publications? ||
          organisation_has_transparency_data_publications?
      end

      def organisation_has_corporate_report_publications?
        return unless organisation.present?

        organisation.has_published_publications_of_type?(
          PublicationType::CorporateReport,
        )
      end

      def organisation_has_chart_url?
        return unless organisation.present?

        organisation.organisation_chart_url.present?
      end

      def organisation_has_freedom_of_information_publications?
        return unless organisation.present?

        organisation.has_published_publications_of_type?(
          PublicationType::FoiRelease,
        )
      end

      def organisation_has_transparency_data_publications?
        return unless organisation.present?

        organisation.has_published_publications_of_type?(
          PublicationType::TransparencyData,
        )
      end

      def page_content_ids_by_menu_heading(menu_heading)
        organisation
          .corporate_information_pages
          .published
          .by_menu_heading(menu_heading)
          .map(&:content_id)
      end

      def payload_for_corporate_reports
        return unless organisation_has_corporate_report_publications?

        corporate_reports_path =
          url_maker
            .publications_filter_path(
              organisation,
              publication_type: 'corporate-reports',
            )

        {
          title: translation_for_group(:corporate_reports, :headings),
          path: corporate_reports_path,
        }
      end

      def payload_for_jobs
        {
          title: 'Jobs',
          url: organisation.jobs_url,
        }
      end

      def payload_for_organisation_chart
        return unless organisation_has_chart_url?

        {
          title: translation_for_group(:organisation_chart),
          url: organisation.organisation_chart_url,
        }
      end

      def payload_for_transparency_data
        return unless organisation_has_transparency_data_publications?

        transparency_data_path =
          url_maker
            .publications_filter_path(
              organisation,
              publication_type: 'transparency-data',
            )

        {
          title: translation_for_group(:transparency),
          path: transparency_data_path,
        }
      end

      def translation_for_group(group, namespace = :corporate_information)
        helpers.t("organisation.#{namespace}.#{group}")
      end
    end

    class CorporateInformationPages
      extend Forwardable

      def self.for(corporate_information_page)
        new(corporate_information_page).call
      end

      def initialize(corporate_information_page)
        self.corporate_information_page = corporate_information_page
      end

      def call
        return {} unless corporate_information_page.about_page? &&
            pages.present?

        {
          corporate_information_pages: pages,
        }
      end

    private

      attr_accessor :corporate_information_page
      def_delegator :corporate_information_page, :owning_organisation, :organisation

      def pages
        @pages ||= [].tap { |pages|
          pages.push(*page_content_ids_for_menu_heading(:jobs_and_contracts))
          pages.push(*page_content_ids_for_menu_heading(:our_information))
          pages.push(page_content_id_for_slug('about-our-services'))
          pages.push(page_content_id_for_slug('personal-information-charter'))
          pages.push(page_content_id_for_slug('publication-scheme'))
          pages.push(page_content_id_for_slug('social-media-use'))
          pages.push(page_content_id_for_slug('welsh-language-scheme'))
        }.compact
      end

      def page_content_ids_for_menu_heading(menu_heading)
        organisation
          .corporate_information_pages
          .published
          .by_menu_heading(menu_heading)
          .map(&:content_id)
      end

      def page_content_id_for_slug(slug)
        organisation
          .corporate_information_pages
          .published
          .for_slug(slug)
          .try(:content_id)
      end
    end

    class Organisation
      extend Forwardable

      def self.for(corporate_information_page)
        new(corporate_information_page).call
      end

      def initialize(corporate_information_page)
        self.corporate_information_page = corporate_information_page
      end

      def call
        return {} unless organisation.present?

        {
          organisation: organisation.content_id
        }
      end

    private

      attr_accessor :corporate_information_page
      def_delegator :corporate_information_page, :owning_organisation, :organisation
    end
  end
end
