module Admin::OrganisationHelper
  def organisation_role_ordering_fields(outer_form, organisation_roles)
    outer_form.fields_for :organisation_roles, organisation_roles do |organisation_role_form|
      role_name = link_to(organisation_role_form.object.role.name, [:edit, :admin, organisation_role_form.object.role.becomes(Role)])
      if organisation_role_form.object.role.current_person
        name = link_to(organisation_role_form.object.role.current_person_name, [:edit, :admin, organisation_role_form.object.role.current_person])
        label_text = "<span class='normal'>#{role_name}</span><br/>#{name}".html_safe
      else
        label_text = "<span class='normal'>#{role_name}</span><br/>#{organisation_role_form.object.role.current_person_name}".html_safe
      end
      tag.div(
        organisation_role_form.text_field(:ordering, label_text:, class: "ordering"),
        class: "well remove-bottom-padding",
      )
    end
  end

  def organisation_tabs(organisation)
    tabs = {
      "Details" => admin_organisation_path(organisation),
      "Contacts" => admin_organisation_contacts_path(organisation),
    }
    if organisation.type.allowed_promotional?
      tabs["Promotional features"] = admin_organisation_promotional_features_path(organisation)
    end

    tabs["Features"] = features_admin_organisation_path(organisation, locale: I18n.default_locale)
    organisation.non_english_translated_locales.each do |locale|
      tabs["Features (#{locale.native_language_name})"] = features_admin_organisation_path(organisation, locale: locale.code)
    end
    tabs["Corporate information pages"] = admin_organisation_corporate_information_pages_path(organisation)
    tabs["More"] = {
      "Social media accounts" => admin_organisation_social_media_accounts_path(organisation),
      "People" => admin_organisation_people_path(organisation),
      "Translations" => admin_organisation_translations_path(organisation),
      "Financial Reports" => admin_organisation_financial_reports_path(organisation),
    }
    tabs
  end

  def organisation_nav_items(organisation, current_path)
    tabs = [
      {
        label: "Details",
        href: admin_organisation_path(organisation),
        current: current_path == admin_organisation_path(organisation),
      },
      {
        label: "Contacts",
        href: admin_organisation_contacts_path(organisation),
        current: current_path == admin_organisation_contacts_path(organisation),
      },
    ]

    if organisation.type.allowed_promotional?
      tabs << {
        label: "Promotional features",
        href: admin_organisation_promotional_features_path(organisation),
        current: current_path == admin_organisation_promotional_features_path(organisation),
      }
    end

    tabs << {
      label: "Features",
      href: features_admin_organisation_path(organisation, locale: I18n.default_locale),
      current: current_path == features_admin_organisation_path(organisation, locale: I18n.default_locale) || current_path == features_admin_organisation_path(organisation),
    }

    organisation.non_english_translated_locales.each do |locale|
      tabs << {
        label: "Features (#{locale.native_language_name})",
        href: features_admin_organisation_path(organisation, locale: locale.code),
        current: current_path == features_admin_organisation_path(organisation, locale: locale.code),
      }
    end

    tabs << {
      label: "Pages",
      href: admin_organisation_corporate_information_pages_path(organisation),
      current: current_path == admin_organisation_corporate_information_pages_path(organisation),
    }

    tabs << {
      label: "Social media accounts",
      href: admin_organisation_social_media_accounts_path(organisation),
      current: current_path == admin_organisation_social_media_accounts_path(organisation),
    }

    tabs << {
      label: "People",
      href: admin_organisation_people_path(organisation),
      current: current_path == admin_organisation_people_path(organisation),
    }

    tabs << {
      label: "Translations",
      href: admin_organisation_translations_path(organisation),
      current: current_path == admin_organisation_translations_path(organisation),
    }

    tabs << {
      label: "Financial Reports",
      href: admin_organisation_financial_reports_path(organisation),
      current: current_path == admin_organisation_financial_reports_path(organisation),
    }

    tabs
  end

  def contact_shown_on_home_page_text(organisation, contact)
    if contact.foi?
      "Yes (in FOI section)"
    elsif organisation.contact_shown_on_home_page?(contact)
      "Yes"
    else
      "No"
    end
  end

  def logo_visibility_css(organisation)
    if organisation.organisation_logo_type_id == OrganisationLogoType::CustomLogo.id
      nil
    else
      "hidden"
    end
  end

  def topical_event_dates_string(topical_event)
    [
      topical_event.start_date.try(:to_date),
      topical_event.end_date.try(:to_date),
    ].compact.map { |date| l(date) }.join(" to ")
  end

  def organisation_context_block(current_user, organisation)
    name = organisation.class.name.underscore.humanize
    current_user.organisation == organisation ? "My #{name.downcase}" : name
  end

  def organisation_index_rows(user_organisation, organisations)
    organisations = ([user_organisation] + organisations).compact

    organisations.each_with_index.map do |organisation, _index|
      [
        {
          text: tag.span(organisation.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: organisation.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(organisation.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(organisation), class: "govuk-link") +
            if organisation.destroyable?
              link_to(sanitize("Delete #{tag.span(organisation.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(organisation), class: "govuk-link gem-link--destructive govuk-!-margin-left-3")
            else
              ""
            end,
        },
      ]
    end
  end

  def people_tab(organisation_roles, title, type)
    [{
      id: "#{title.downcase.gsub(' ', '_')}_tab",
      label: title,
      tab_data_attributes: {
        module: "gem-track-click",
        "track-category": "tab",
        "track-action": "organisation-people-tab",
        "track-label": title,
      },
      content: render("admin/organisation_people/order", organisation_roles:, title:, type:),
    }]
  end
end
