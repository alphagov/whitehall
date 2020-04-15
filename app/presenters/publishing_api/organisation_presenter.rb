module PublishingApi
  class OrganisationPresenter
    include Rails.application.routes.url_helpers
    include ApplicationHelper
    include FilterRoutesHelper
    # This is so we can get the extra text for the summary field
    include OrganisationHelper
    # This is a hack to get the OrganisationHelper to work in this context
    include ActionView::Helpers::UrlHelper

    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: text_summary,
        details: details,
        document_type: item.class.name.underscore,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: schema_name,
      )
      content.merge!(
        PayloadBuilder::PolymorphicPath.for(item, additional_routes: additional_routes),
      )
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {
        ordered_contacts: contacts_links,
        ordered_foi_contacts: foi_contacts_links,
        ordered_parent_organisations: parent_organisation_links,
        ordered_child_organisations: child_organisation_links,
        ordered_successor_organisations: successor_organisation_links,
        ordered_high_profile_groups: high_profile_groups_links,
        ordered_roles: roles_links,
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
        acronym: acronym,
        alternative_format_contact_email: alternative_format_contact_email,
        body: html_summary,
        brand: brand,
        logo: {
          formatted_title: formatted_title,
          crest: crest,
          image: image,
        }.compact!,
        foi_exempt: foi_exempt,
        ordered_corporate_information_pages: corporate_information_pages,
        secondary_corporate_information_pages: secondary_corporate_information_pages,
        ordered_featured_links: featured_links,
        ordered_featured_documents: featured_documents,
        ordered_promotional_features: promotional_features,
        ordered_ministers: ministers,
        ordered_board_members: board_members,
        ordered_military_personnel: military_personnel,
        ordered_traffic_commissioners: traffic_commissioners,
        ordered_chief_professional_officers: chief_professional_officers,
        ordered_special_representatives: special_representatives,
        important_board_members: important_board_members,
        organisation_featuring_priority: organisation_featuring_priority,
        organisation_govuk_status: organisation_govuk_status,
        organisation_type: organisation_type,
        organisation_political: organisation_political,
        social_media_links: social_media_links,
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
      unless item.organisation_type.executive_office? ||
          item.organisation_type.civil_service? ||
          item.closed?
        if item.parent_organisations.any? || item.supporting_bodies.any?
          "\n\n#{organisation_display_name_including_parental_and_child_relationships(item)}"
        end
      end
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
        url: ActionController::Base.helpers.image_url(
          item.logo.url, host: Whitehall.public_asset_host
        ),
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
            href: Whitehall.url_maker.public_document_path(about_page),
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
          href: Whitehall.url_maker.public_document_path(cip),
        }
      end

      item.corporate_information_pages.published.by_menu_heading(:jobs_and_contracts).each do |cip|
        cips << {
          title: cip.title,
          href: Whitehall.url_maker.public_document_path(cip),
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
        sentences << I18n.t("worldwide_organisation.corporate_information.publication_scheme_html",
                            link: t_corporate_information_page_link(item, "publication-scheme"))
      end

      if item.corporate_information_pages.published.for_slug("welsh-language-scheme").present?
        sentences << I18n.t("worldwide_organisation.corporate_information.welsh_language_scheme_html",
                            link: t_corporate_information_page_link(item, "welsh-language-scheme"))
      end

      if item.corporate_information_pages.published.for_slug("personal-information-charter").present?
        sentences << I18n.t("worldwide_organisation.corporate_information.personal_information_charter_html",
                            link: t_corporate_information_page_link(item, "personal-information-charter"))
      end

      if item.corporate_information_pages.published.for_slug("social-media-use").present?
        sentences << I18n.t("worldwide_organisation.corporate_information.social_media_use_html",
                            link: t_corporate_information_page_link(item, "social-media-use"))
      end

      if item.corporate_information_pages.published.for_slug("about-our-services").present?
        sentences << I18n.t("worldwide_organisation.corporate_information.about_our_services_html",
                            link: t_corporate_information_page_link(item, "about-our-services"))
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
        Whitehall.url_maker.public_document_path(page),
        class: "brand__color",
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

    def featured_documents
      item.feature_list_for_locale(I18n.locale).current.limit(6).map do |feature|
        if feature.document
          featured_documents_editioned(feature)
        elsif feature.topical_event
          featured_documents_topical_event(feature)
        elsif feature.offsite_link
          featured_documents_offsite_link(feature)
        end
      end
    end

    def featured_documents_editioned(feature)
      # Editioned formats (like news) that have been featured
      edition = feature.document.published_edition
      {
        title: edition.title,
        href: Whitehall.url_maker.public_document_path(edition),
        image: {
          url: feature.image.url,
          alt_text: feature.alt_text,
        },
        summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(edition.summary),
        public_updated_at: edition.public_timestamp,
        document_type: edition.display_type,
      }
    end

    def featured_documents_topical_event(feature)
      # Topical events that have been featured
      topical_event = feature.topical_event
      {
        title: topical_event.name,
        href: Whitehall.url_maker.polymorphic_path(topical_event),
        image: {
          url: feature.image.url,
          alt_text: feature.alt_text,
        },
        summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(topical_event.description),
        public_updated_at: topical_event.start_date,
        document_type: nil, # We don't want a type for topical events
      }
    end

    def featured_documents_offsite_link(feature)
      # Offsite links that have been featured
      offsite_link = feature.offsite_link
      {
        title: offsite_link.title,
        href: offsite_link.url,
        image: {
          url: feature.image.url,
          alt_text: feature.alt_text,
        },
        summary: Whitehall::GovspeakRenderer.new.govspeak_to_html(offsite_link.summary),
        public_updated_at: offsite_link.date,
        document_type: offsite_link.display_type,
      }
    end

    def promotional_features
      return [] unless item.type.allowed_promotional?

      item.promotional_features.map do |promotional_feature|
        {
          title: promotional_feature.title,
          items: promotional_feature.items.map do |promotional_feature_item|
            {
              title: promotional_feature_item.title,
              href: promotional_feature_item.title_url,
              summary: promotional_feature_item.summary,
              image: {
                url: promotional_feature_item.image_url,
                alt_text: promotional_feature_item.image_alt_text,
              },
              double_width: promotional_feature_item.double_width,
              links: promotional_feature_item.links.map do |link|
                {
                  title: link.text,
                  href: link.url,
                }
              end,
            }
          end,
        }
      end
    end

    def ministers
      people_in_role("ministerial")
    end

    def board_members
      people_in_role("management")
    end

    def military_personnel
      people_in_role("military")
    end

    def traffic_commissioners
      people_in_role("traffic_commissioner")
    end

    def chief_professional_officers
      people_in_role("chief_professional_officer")
    end

    def special_representatives
      people_in_role("special_representative")
    end

    def people_in_role(role_type)
      item.send("#{role_type}_roles")
        .order("organisation_roles.ordering")
        .reduce([]) do |ary, role|
          person = role.current_person
          unless person.nil?
            name_prefix = "The Rt Hon" if person.privy_counsellor
            full_name = "#{person.title} #{person.forename} #{person.surname} #{person.letters}".strip
            role_href = "/government/ministers/#{role.slug}" if role.ministerial?
            person_object = {
              name_prefix: name_prefix,
              name: full_name,
              role: role.name,
              href: "/government/people/#{person.slug}",
              role_href: role_href,
              payment_type: role.role_payment_type&.name,
              attends_cabinet_type: role.attends_cabinet_type&.name,
            }

            unless person.image.url.nil?
              person_object[:image] = {
                url: person.image.url,
                alt_text: full_name,
              }
            end

            ary << person_object
          end

          ary
        end
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
