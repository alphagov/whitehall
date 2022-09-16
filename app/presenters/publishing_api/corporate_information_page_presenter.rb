module PublishingApi
  class CorporateInformationPagePresenter
    include UpdateTypeHelper

    SCHEMA_NAME = "corporate_information_page".freeze

    attr_reader :update_type

    def initialize(corporate_information_page, update_type: nil)
      self.corporate_information_page = corporate_information_page
      self.update_type =
        update_type || default_update_type(corporate_information_page)
    end

    delegate :content_id, to: :corporate_information_page

    def content
      BaseItemPresenter
        .new(corporate_information_page, update_type:)
        .base_attributes
        .merge(PayloadBuilder::PublicDocumentPath.for(corporate_information_page))
        .merge(
          description: corporate_information_page.summary,
          details:,
          document_type:,
          public_updated_at:,
          rendering_app: corporate_information_page.rendering_app,
          schema_name: SCHEMA_NAME,
          links: edition_links,
          auth_bypass_ids: [corporate_information_page.auth_bypass_id],
        )
    end

    def links
      # TODO: Previously, this presenter was sending all links to the
      # Publishing API at both the document level, and edition
      # level. This is probably redundant, and hopefully can be
      # improved.
      edition_links
    end

    def edition_links
      links_presenter.extract(
        %i[
          organisations
          parent
        ],
      ).merge(CorporateInformationPages.for(corporate_information_page))
    end

    def document_type
      display_type_key
    end

  private

    attr_accessor :corporate_information_page
    attr_writer :update_type

    delegate :display_type_key, to: :corporate_information_page

    def base_details
      {
        body:,
      }
    end

    def body
      Whitehall::GovspeakRenderer
        .new
        .govspeak_edition_to_html(corporate_information_page)
    end

    def details
      base_details
        .merge(change_history)
        .merge(CorporateInformationGroups.for(corporate_information_page))
        .merge(Organisation.for(corporate_information_page))
        .merge(PayloadBuilder::TagDetails.for(corporate_information_page))
        .merge(PayloadBuilder::Attachments.for(corporate_information_page))
    end

    def links_presenter
      @links_presenter ||= LinksPresenter.new(corporate_information_page)
    end

    def public_updated_at
      public_updated_at = corporate_information_page.public_timestamp ||
        corporate_information_page.updated_at

      public_updated_at.rfc3339
    end

    def change_history
      return {} if corporate_information_page.change_history.blank?

      # Some speeches and corporate information pages don't seem to
      # have first_published_at data, so ignore those change notes to
      # avoid violating the relevant content schema.
      changes_with_public_timestamps =
        corporate_information_page
          .change_history
          .select { |change| change[:public_timestamp].present? }

      { change_history: changes_with_public_timestamps.as_json }
    end

    class CorporateInformationGroups
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
        return {} unless corporate_information_page.about_page?

        {
          corporate_information_groups: corporate_information_groups
            .reject { |group| group[:contents].empty? },
        }
      end

    private

      attr_accessor :context, :corporate_information_page, :url_maker

      delegate :helpers, to: :context
      delegate :owning_organisation, to: :corporate_information_page
      alias_method :organisation, :owning_organisation

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
        end
      end

      def contents_for_jobs_and_contacts
        [].tap do |contents|
          contents.push(*page_content_ids_by_menu_heading(:jobs_and_contracts))
          contents.push(payload_for_jobs)
        end
      end

      def organisation_has_chart_url?
        return if organisation.blank?

        organisation.organisation_chart_url.present?
      end

      def page_content_ids_by_menu_heading(menu_heading)
        organisation
          .corporate_information_pages
          .published
          .by_menu_heading(menu_heading)
          .map(&:content_id)
      end

      def payload_for_jobs
        {
          title: "Jobs",
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

      def translation_for_group(group, namespace = :corporate_information)
        helpers.t("organisation.#{namespace}.#{group}")
      end
    end

    class CorporateInformationPages
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

      delegate :owning_organisation, to: :corporate_information_page
      alias_method :organisation, :owning_organisation

      def pages
        @pages ||= [].tap { |pages|
          pages.push(*page_content_ids_for_menu_heading(:jobs_and_contracts))
          pages.push(*page_content_ids_for_menu_heading(:our_information))
          pages.push(page_content_id_for_slug("about-our-services"))
          pages.push(page_content_id_for_slug("personal-information-charter"))
          pages.push(page_content_id_for_slug("publication-scheme"))
          pages.push(page_content_id_for_slug("social-media-use"))
          pages.push(page_content_id_for_slug("welsh-language-scheme"))
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
      def self.for(corporate_information_page)
        new(corporate_information_page).call
      end

      def initialize(corporate_information_page)
        self.corporate_information_page = corporate_information_page
      end

      def call
        return {} if organisation.blank?

        {
          organisation: organisation.content_id,
        }
      end

    private

      attr_accessor :corporate_information_page

      delegate :owning_organisation, to: :corporate_information_page
      alias_method :organisation, :owning_organisation
    end
  end
end
