module PublishingApi
  class OrganisationPresenter
    include Rails.application.routes.url_helpers
    include ApplicationHelper
    # This is so we can get the extra text for the summary field
    include OrganisationHelper
    # This is a hack to get the OrganisationHelper to work in this context
    include ActionView::Helpers::UrlHelper
    include FeaturedDocumentsPresenter

    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        update_type:,
      ).base_attributes

      content.merge!(
        description: text_summary,
        details:,
        document_type: item.class.name.underscore,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name:,
      )
      content.merge!(
        PayloadBuilder::PolymorphicPath.for(item, additional_routes:),
      )
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {
        ordered_board_members: people_content_ids(role: "management"),
        ordered_chief_professional_officers: people_content_ids(role: "chief_professional_officer"),
        ordered_child_organisations: child_organisation_links,
        ordered_contacts: contacts_links,
        ordered_foi_contacts: foi_contacts_links,
        ordered_high_profile_groups: high_profile_groups_links,
        ordered_military_personnel: people_content_ids(role: "military"),
        ordered_ministers: people_content_ids(role: "ministerial"),
        ordered_parent_organisations: parent_organisation_links,
        ordered_roles: roles_links,
        ordered_special_representatives: people_content_ids(role: "special_representative"),
        ordered_successor_organisations: successor_organisation_links,
        ordered_traffic_commissioners: people_content_ids(role: "traffic_commissioner"),
        primary_publishing_organisation: [content_id],
      }
    end

  private

    def schema_name
      "organisation"
    end

    def additional_routes
      return [] if court_or_tribunal?

      %w[atom]
    end

    def details
      details = {
        acronym:,
        alternative_format_contact_email:,
        body: html_summary,
        brand:,
        logo: {
          formatted_title:,
          crest:,
          image:,
        }.compact!,
        foi_exempt:,
        ordered_corporate_information_pages: corporate_information_pages,
        secondary_corporate_information_pages:,
        ordered_featured_links: featured_links,
        ordered_featured_documents: featured_documents(item, item.class::FEATURED_DOCUMENTS_DISPLAY_LIMIT),
        ordered_promotional_features: promotional_features,
        important_board_members:,
        organisation_featuring_priority:,
        organisation_govuk_status:,
        organisation_type:,
        organisation_political:,
        social_media_links:,
      }
      details[:default_news_image] = default_news_image if default_news_image
      details
    end

    def acronym
      item.acronym
    end

    def alternative_format_contact_email
      item.alternative_format_contact_email
    end

    def govspeak_summary
      if item.court_or_hmcts_tribunal?
        item.body
      else
        "#{item.summary}#{parent_child_relationships_text}"
      end
    end

    def html_summary
      Whitehall::GovspeakRenderer.new.govspeak_to_html(govspeak_summary)
    end

    def organisation_political
      item.political
    end

    def text_summary
      Govspeak::Document.new(govspeak_summary).to_text
    end

    def parent_child_relationships_text
      return if item.organisation_type.executive_office? || item.organisation_type.civil_service? || item.closed?
      return if item.parent_organisations.empty? && item.supporting_bodies.empty?

      "\n\n#{organisation_display_name_including_parental_and_child_relationships(item)}"
    end

    def brand
      brand_colour = item.organisation_brand_colour
      brand_colour ? brand_colour.class_name : nil
    end

    def formatted_title
      format_with_html_line_breaks(item.logo_formatted_name)
    end

    def crest
      crest_is_publishable? ? item.organisation_logo_type.class_name : nil
    end

    def crest_is_publishable?
      class_name = item.organisation_logo_type.class_name
      class_name != "no-identity" && class_name != "custom"
    end

    def image
      return unless item.custom_logo_selected?

      {
        url: item.logo.url,
        alt_text: item.name,
      }
    end

    def foi_exempt
      item.foi_exempt
    end

    def corporate_information_pages
      cips = []

      if item.organisation_type.executive_office? || item.organisation_type.civil_service?
        about_page = item.corporate_information_pages.published.for_slug("about")

        if about_page.present?
          cips << {
            title: I18n.t("corporate_information_page.type.title.about"),
            href: about_page.public_path,
          }
        end
      end

      if item.organisation_chart_url.present?
        cips << {
          title: I18n.t("organisation.corporate_information.organisation_chart"),
          href: item.organisation_chart_url,
        }
      end

      item.corporate_information_pages.published.by_menu_heading(:our_information).each do |cip|
        cips << {
          title: cip.title,
          href: cip.public_path,
        }
      end

      item.corporate_information_pages.published.by_menu_heading(:jobs_and_contracts).each do |cip|
        cips << {
          title: cip.title,
          href: cip.public_path,
        }
      end

      cips << {
        title: I18n.t("organisation.corporate_information.jobs"),
        href: item.jobs_url,
      }

      cips
    end

    def secondary_corporate_information_pages
      sentences = []

      if item.corporate_information_pages.published.for_slug("publication-scheme").present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.publication_scheme_html",
          link: t_corporate_information_page_link(item, "publication-scheme"),
        )
      end

      if item.corporate_information_pages.published.for_slug("welsh-language-scheme").present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.welsh_language_scheme_html",
          link: t_corporate_information_page_link(item, "welsh-language-scheme"),
        )
      end

      if item.corporate_information_pages.published.for_slug("personal-information-charter").present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.personal_information_charter_html",
          link: t_corporate_information_page_link(item, "personal-information-charter"),
        )
      end

      if item.corporate_information_pages.published.for_slug("social-media-use").present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.social_media_use_html",
          link: t_corporate_information_page_link(item, "social-media-use"),
        )
      end

      if item.corporate_information_pages.published.for_slug("about-our-services").present?
        sentences << I18n.t(
          "worldwide_organisation.corporate_information.about_our_services_html",
          link: t_corporate_information_page_link(item, "about-our-services"),
        )
      end

      sentences.join(" ")
    end

    def t_corporate_information_page_type_link_text(page)
      if I18n.exists?("corporate_information_page.type.link_text.#{page.display_type_key}")
        I18n.t("corporate_information_page.type.link_text.#{page.display_type_key}")
      else
        I18n.t("corporate_information_page.type.title.#{page.display_type_key}")
      end
    end

    def t_corporate_information_page_link(organisation, slug)
      page = organisation.corporate_information_pages.published.for_slug(slug)
      page.extend(UseSlugAsParam)
      link_to(
        t_corporate_information_page_type_link_text(page),
        page.public_path,
        class: "govuk-link brand__color",
      )
    end

    def featured_links
      item.visible_featured_links.map do |link|
        {
          title: link.title,
          href: link.url,
        }
      end
    end

    def promotional_features
      return [] unless item.type.allowed_promotional?

      item.promotional_features.map do |promotional_feature|
        {
          title: promotional_feature.title,
          items: promotional_feature.items.map do |promotional_feature_item|
            if promotional_feature_item.youtube_video_id.present?
              promotional_feature_item_youtube_hash(promotional_feature_item)
            else
              promotional_feature_item_image_hash(promotional_feature_item)
            end
          end,
        }
      end
    end

    def promotional_feature_item_youtube_hash(promotional_feature_item)
      promotional_feature_item_hash_common(promotional_feature_item).merge({
        youtube_video: {
          id: promotional_feature_item.youtube_video_id,
          alt_text: promotional_feature_item.youtube_video_alt_text,
        },
      })
    end

    def promotional_feature_item_image_hash(promotional_feature_item)
      promotional_feature_item_hash_common(promotional_feature_item).merge({
        image: {
          url: promotional_feature_item.image_url,
          alt_text: promotional_feature_item.image_alt_text,
        },
      })
    end

    def promotional_feature_item_hash_common(promotional_feature_item)
      {
        title: promotional_feature_item.title,
        href: promotional_feature_item.title_url,
        summary: promotional_feature_item.summary,
        links: promotional_feature_item.links.map do |link|
          {
            title: link.text,
            href: link.url,
          }
        end,
      }.compact
    end

    def people_content_ids(role:)
      item.send("#{role}_roles")
        .order("organisation_roles.ordering")
        .map(&:current_person)
        .compact
        .map(&:content_id)
    end

    def important_board_members
      item.important_board_members
    end

    def organisation_featuring_priority
      item.homepage_type
    end

    def organisation_govuk_status
      {
        status: consolidated_organisation_govuk_status,
        url: organisation_url,
        updated_at: item.closed_at,
      }
    end

    def consolidated_organisation_govuk_status
      if item.closed?
        item.govuk_closed_status
      else
        item.govuk_status
      end
    end

    def organisation_url
      item.url unless item.live?
    end

    def organisation_type
      item.organisation_type_key.to_s
    end

    def court_or_tribunal?
      item.court_or_hmcts_tribunal?
    end

    def social_media_links
      item.social_media_accounts.map do |account|
        {
          service_type: account.service_name.parameterize,
          title: account.display_name,
          href: account.url,
        }
      end
    end

    # Publishing API will reject duplicate content_ids so distinct/uniq
    # is used for all link types below

    def contacts_links
      item.home_page_contacts.pluck(:content_id).uniq
    end

    def foi_contacts_links
      item.foi_contacts.pluck(:content_id).uniq
    end

    def parent_organisation_links
      item.parent_organisations.distinct.pluck(:content_id)
    end

    def child_organisation_links
      item.child_organisations.distinct.pluck(:content_id)
    end

    def successor_organisation_links
      item.superseding_organisations.distinct.pluck(:content_id)
    end

    def high_profile_groups_links
      item.sub_organisations.distinct.pluck(:content_id)
    end

    def roles_links
      item.roles.distinct.pluck(:content_id)
    end

    def default_news_image
      return unless item.default_news_image
      return { url: default_news_image_url } if default_news_image_is_svg?

      {
        url: default_news_image_url(:s300),
        high_resolution_url: default_news_image_url(:s960),
      }
    end

    def default_news_image_url(size = nil)
      size ? item.default_news_image.file.url(size) : item.default_news_image.file.url
    end

    def default_news_image_is_svg?
      content_type = item.default_news_image.file.content_type
      content_type && content_type =~ /svg/
    end
  end
end
