module PublishingApi
  class OrganisationPresenter
    include Rails.application.routes.url_helpers
    include ApplicationHelper
    include FilterRoutesHelper
    # This is so we can get the extra text for the summary field
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
        description: nil,
        details: details,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: schema_name,
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
      content.merge!(PayloadBuilder::AnalyticsIdentifier.for(item))
    end

    def links
      {
        ordered_contacts: contacts_links,
        ordered_foi_contacts: foi_contacts_links,
        ordered_featured_policies: featured_policies_links,
        ordered_parent_organisations: parent_organisation_links,
        ordered_child_organisations: child_organisation_links,
        ordered_successor_organisations: successor_organisation_links,
        ordered_high_profile_groups: high_profile_groups_links,
        ordered_roles: roles_links,
      }
    end

  private

    def schema_name
      "organisation"
    end

    def details
      {
        acronym: acronym,
        body: summary,
        brand: brand,
        logo: {
          formatted_title: formatted_title,
          crest: crest,
          image: image,
        }.compact!,
        foi_exempt: foi_exempt,
        ordered_corporate_information_pages: corporate_information_pages,
        ordered_featured_links: featured_links,
        ordered_featured_documents: featured_documents,
        ordered_promotional_features: promotional_features,
        ordered_ministers: ministers,
        ordered_board_members: board_members,
        ordered_military_personnel: military_personnel,
        ordered_traffic_commissioners: traffic_commissioners,
        ordered_chief_professional_officers: chief_professional_officers,
        ordered_special_representatives: special_representatives,
        organisation_featuring_priority: organisation_featuring_priority,
        organisation_govuk_status: organisation_govuk_status,
        organisation_type: organisation_type,
        social_media_links: social_media_links,
      }
    end

    def acronym
      item.acronym
    end

    def summary
      "#{item.summary}#{parent_child_relationships_text}"
    end

    def parent_child_relationships_text
      if item.parent_organisations.any? || item.supporting_bodies.any?
        "\n\n#{organisation_display_name_including_parental_and_child_relationships(item)}"
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

      if item.organisation_chart_url.present?
        cips << {
          title: I18n.t('organisation.corporate_information.organisation_chart'),
          href: item.organisation_chart_url
        }
      end

      item.corporate_information_pages.published.by_menu_heading(:our_information).each do |cip|
        cips << {
          title: cip.title,
          href: Whitehall.url_maker.public_document_path(cip)
        }
      end

      cips << {
        title: I18n.t('organisation.headings.corporate_reports'),
        href: publications_filter_path(item, publication_type: 'corporate-reports')
      }

      cips << {
        title: I18n.t('organisation.corporate_information.transparency'),
        href: publications_filter_path(item, publication_type: 'transparency-data')
      }

      item.corporate_information_pages.published.by_menu_heading(:jobs_and_contracts).each do |cip|
        cips << {
          title: cip.title,
          href: Whitehall.url_maker.public_document_path(cip)
        }
      end

      cips << {
        title: I18n.t('organisation.corporate_information.jobs'),
        href: item.jobs_url
      }

      cips
    end

    def featured_links
      item.visible_featured_links.map do |link|
        {
          title: link.title,
          href: link.url
        }
      end
    end

    def featured_documents
      item.feature_list_for_locale(I18n.locale).current.map do |feature|
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
          alt_text: feature.alt_text
        },
        summary: edition.summary,
        public_updated_at: edition.public_timestamp,
        document_type: edition.display_type
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
          alt_text: feature.alt_text
        },
        summary: topical_event.description,
        public_updated_at: topical_event.start_date,
        document_type: nil # We don't want a type for topical events
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
          alt_text: feature.alt_text
        },
        summary: offsite_link.summary,
        public_updated_at: offsite_link.date,
        document_type: offsite_link.humanized_link_type
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
                url: promotional_feature_item.image,
                alt_text: promotional_feature_item.image_alt_text
              },
              double_width: promotional_feature_item.double_width,
              links: promotional_feature_item.links.map do |link|
                {
                  title: link.text,
                  href: link.url
                }
              end
            }
          end
        }
      end
    end

    def ministers
      people_in_role("ministerial")
    end

    def board_members
      people_in_role("management", important_people: item.important_board_members)
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

    def people_in_role(role_type, important_people: 0)
      item.send("#{role_type}_roles")
        .order("organisation_roles.ordering")
        .reduce([]) do |ary, role|
          person = role.current_person
          unless person.nil?
            name_prefix = "The Rt Hon" if person.privy_counsellor
            full_name = "#{person.title} #{person.forename} #{person.surname} #{person.letters}".strip
            role_href = Whitehall.url_maker.polymorphic_path(role) if role.ministerial?
            person_object = {
              name_prefix: name_prefix,
              name: full_name,
              role: role.name,
              href: Whitehall.url_maker.polymorphic_path(person),
              role_href: role_href,
              payment_type: role.role_payment_type&.name,
              attends_cabinet_type: role.attends_cabinet_type&.name
            }

            unless person.image.url.nil? ||
                (important_people.positive? && ary.count >= important_people)
              person_object[:image] = {
                url: person.image.url,
                alt_text: full_name
              }
            end

            ary << person_object
          end

          ary
        end
    end

    def organisation_featuring_priority
      item.homepage_type
    end

    def organisation_govuk_status
      {
        status: consolidated_organisation_govuk_status,
        updated_at: item.closed_at
      }
    end

    def consolidated_organisation_govuk_status
      if item.closed?
        item.govuk_closed_status
      else
        item.govuk_status
      end
    end

    def organisation_type
      item.organisation_type_key.to_s
    end

    def social_media_links
      item.social_media_accounts.map do |account|
        {
          service_type: account.service_name.parameterize,
          title: account.display_name,
          href: account.url
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

    def featured_policies_links
      item.featured_policies.order(:ordering).distinct.pluck(:policy_content_id)
    end

    def roles_links
      item.roles.distinct.pluck(:content_id)
    end
  end
end
