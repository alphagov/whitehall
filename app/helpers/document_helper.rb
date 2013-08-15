module DocumentHelper
  include ApplicationHelper
  include CountryHelper
  include DocumentSeriesHelper
  include MinisterialRolesHelper
  include PolicyHelper
  include PolicyAdvisoryGroupsHelper
  include RoleAppointmentsHelper
  include TopicsHelper
  include TranslationHelper

  def html_version_see_more_display_type(edition)
    edition.is_a?(Consultation) ? 'consultation' : 'publication'
  end

  def published_or_updated(edition)
    edition.first_published_version? ? t('document.published') : t('document.updated')
  end

  def edition_organisation_class(edition)
    if organisation = edition.sorted_organisations.first
      organisation.slug
    else
      'unknown_organisation'
    end
  end

  def national_statistics_logo(edition)
    if edition.national_statistic?
      content_tag :div, class: 'national-statistic' do
        image_tag "/government/assets/national-statistics.png", alt: "National Statistic", class: "national-statistics-logo"
      end
    end
  end

  def only_applies_to_nations_list(document)
    if document.respond_to?(:nation_inapplicabilities) && document.nation_inapplicabilities.any?
      content_tag :span, "#{document.applicable_nations.map(&:name).sort.to_sentence}#{see_alternative_urls_for_inapplicable_nations(document)}".html_safe, class: 'inapplicable-nations'
    end
  end

  def see_alternative_urls_for_inapplicable_nations(edition)
    with_alternative_urls = edition.nation_inapplicabilities.select do |ni|
      ni.alternative_url.present?
    end
    if with_alternative_urls.any?
      " (see #{edition.format_name} for ".html_safe + list_of_links_to_inapplicable_nations(with_alternative_urls) + ")".html_safe
    end
  end

  def list_of_links_to_inapplicable_nations(nation_inapplicabilities)
    nation_inapplicabilities.map { |i| link_to_inapplicable_nation(i) }.to_sentence.html_safe
  end

  def link_to_inapplicable_nation(nation_inapplicability)
    if nation_inapplicability.alternative_url.present?
      link_to nation_inapplicability.nation.name, nation_inapplicability.alternative_url, class: "country", id: "nation_inapplicability_#{nation_inapplicability.id}", rel: "external"
    else
      nation_inapplicability.nation.name
    end
  end

  def array_of_links_to_statistical_data_sets(data_sets)
    data_sets.map { |data_set| link_to data_set.title, public_document_path(data_set) }
  end

  MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document"
  MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet"
  MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation"

  def humanized_content_type(file_extension)
    file_extension_vs_humanized_content_type = {
      "pdf" => content_tag(:abbr, 'PDF', title: 'Portable Document Format'),
      "csv" => content_tag(:abbr, 'CSV', title: 'Comma-separated Values'),
      "rtf" => content_tag(:abbr, 'RTF', title: 'Rich Text Format'),
      "rdf" => content_tag(:abbr, 'RDF', title: 'Resource Description Framework'),
      "png" => content_tag(:abbr, 'PNG', title: 'Portable Network Graphic'),
      "jpg" => "JPEG",
      "zip" => content_tag(:abbr, 'ZIP', title: 'Zip archive'),
      "doc" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
      "docx" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
      "xls" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
      "xlsx" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
      "ppt" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
      "pptx" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
      "odt" => content_tag(:abbr, 'ODT', title: 'OpenDocument Text document'),
      "ods" => content_tag(:abbr, 'ODS', title: 'OpenDocument Spreadsheet'),
      "html" => content_tag(:abbr, 'HTML', title: 'Hypertext Markup Language'),
    }
    file_extension_vs_humanized_content_type[file_extension.downcase] if file_extension.present?
  end

  def attachment_reference(attachment)
    ref = []
    ref << "ISBN " + content_tag(:span, attachment.isbn, class: "isbn") if attachment.isbn.present?
    ref << content_tag(:span, attachment.unique_reference, class: "unique_reference") if attachment.unique_reference.present?
    if attachment.command_paper_number.present?
      ref << content_tag(:span, attachment.command_paper_number, class: "command_paper_number")
    end
    if attachment.hoc_paper_number.present?
      ref << content_tag(:span, "HC #{attachment.hoc_paper_number}", class: 'house_of_commons_paper_number') + ' ' +
          content_tag(:span, attachment.parliamentary_session, class: 'parliamentary_session')
    end

    ref.join(', ').html_safe
  end

  def attachment_thumbnail(attachment)
    if attachment.pdf?
      image_tag(attachment.url(:thumbnail), alt: "")
    elsif attachment.html?
      image_tag('pub-cover-html.png', alt: "")
    elsif %w{doc docx odt}.include? attachment.file_extension
      image_tag('pub-cover-doc.png', alt: "")
    elsif %w{xls xlsx ods csv}.include? attachment.file_extension
      image_tag('pub-cover-spreadsheet.png', alt: "")
    else
      image_tag('pub-cover.png', alt: "")
    end
  end

  def alternative_format_order_link(attachment, alternative_format_contact_email)
    attachment_info = []
    attachment_info << "Title: #{attachment.title}"
    attachment_info << "ISBN: #{attachment.isbn}" if attachment.isbn
    attachment_info << "Unique reference: #{attachment.unique_reference}" if attachment.unique_reference
    attachment_info << "Command paper number: #{attachment.command_paper_number}" if attachment.command_paper_number
    if attachment.hoc_paper_number
      attachment_info << "House of Commons paper number: #{attachment.hoc_paper_number}"
      attachment_info << "Parliamentary session: #{attachment.parliamentary_session}"
    end
    mail_to alternative_format_contact_email, alternative_format_contact_email,
      subject: "Request for '#{attachment.title}' in an alternative format",
      body: %(

Details of document required:

#{attachment_info.join("\n")}
      )
  end

  def attachment_references(attachment)
    references = []
    references << "ISBN: #{attachment.isbn}" if attachment.isbn.present?
    references << "Unique reference: #{attachment.unique_reference}" if attachment.unique_reference.present?
    references << "Command paper number: #{attachment.command_paper_number}" if attachment.command_paper_number.present?
    references << "HC: #{attachment.hoc_paper_number} #{attachment.parliamentary_session}" if attachment.hoc_paper_number.present?
    prefix = references.size == 1 ? "and its reference" : "and its references"
    references.any? ? ", #{prefix} (" + references.join(", ") + ")" : ""
  end

  def attachment_attributes(attachment)
    attributes = []
    attributes << content_tag(:span, humanized_content_type(attachment.file_extension), class: 'type')
    attributes << content_tag(:span, number_to_human_size(attachment.file_size), class: 'file-size')
    attributes << content_tag(:span, pluralize(attachment.number_of_pages, "page") , class: 'page-length') if attachment.number_of_pages.present?
    attributes.join(', ').html_safe
  end

  def native_language_name_for(locale)
    Locale.new(locale).native_language_name
  end

  def link_to_translated_object(object, locale)
    object = object.is_a?(Array) ? object : object.to_model

    path = case object
    when Edition
      public_document_path(object, locale: locale)
    when CorporateInformationPage
      polymorphic_path([object.organisation, object], locale: locale)
    else
      polymorphic_path(object, locale: locale)
    end
    link_to native_language_name_for(locale), path
  end

  def document_metadata(document, policies = [], topics = [], links_only = false)
    metadata = []
    if policies.any?
      metadata << {
        title: t('document.headings.policies', count: policies.length),
        data: array_of_links_to_policies(policies),
        classes: ['document-policies']
      }
    end
    if topics.any?
      metadata << {
        title: t('document.headings.topics', count: topics.length),
        data: array_of_links_to_topics(topics),
        classes: ['document-topics']
      }
    end
    if document.respond_to?(:topical_events) && document.topical_events.any?
      metadata << {
        title: t('document.headings.topical_events', count: document.topical_events.length),
        data: array_of_links_to_topical_events(document.topical_events),
        classes: ['document-topical-events']
      }
    end
    if !(document.respond_to?(:statistics?) && document.statistics?)
      if document.respond_to?(:ministerial_roles) && document.ministerial_roles.any?
        metadata << {

          title: t('document.headings.ministers', count: document.ministerial_roles.length),
          data: array_of_links_to_ministers(document.ministerial_roles),
          classes: ['document-ministerial-roles']
        }
      end
      if document.respond_to?(:delivered_by_minister?)
        if document.person_override?
          if not links_only
            metadata << {
              title: t_delivery_title(document),
              data: [document.person_override],
              classes: ['document-delivered-by-minister']
            }
          end
        else
          metadata << {
            title: t_delivery_title(document),
            data: [link_to_person(document.role_appointment.person)],
            classes: ['document-delivered-by-minister']
          }
        end
      end
    end
    if document.has_operational_field?
      metadata << {
        title: t('document.headings.field_of_operation'),
        data: [link_to(document.operational_field.name, document.operational_field)],
        classes: ['document-operational-field']
      }
    end
    if document.respond_to?(:role_appointments) && document.role_appointments.any?
      metadata << {
        title: t('document.headings.ministers', count: document.role_appointments.length),
        data: array_of_links_to_role_appointments(document.role_appointments),
        classes: ['document-role-appointments']
      }
    end
    if document.respond_to?(:world_locations) && document.world_locations.any?
      metadata << {
        title: t('document.headings.world_locations', count: document.world_locations.length),
        data: array_of_links_to_world_locations(document.world_locations),
        classes: ['document-world-locations']
      }
    end
    if document.respond_to?(:worldwide_organisations) && document.worldwide_organisations.any?
      metadata << {
        title: t('document.headings.worldwide_organisations', count: document.worldwide_organisations.length),
        data: array_of_links_to_worldwide_organisations(document.worldwide_organisations),
        classes: ['document-worldwide-organisations']
      }
    end
    if document.respond_to?(:inapplicable_nations) && document.inapplicable_nations.any? && !links_only
      metadata << {
        title: t('document.headings.applies_to_nations'),
        data: [only_applies_to_nations_list(document)],
        classes: ['document-inapplicable-nations']
      }
    end
    if document.respond_to?(:policy_team) && document.policy_team
      metadata << {
        title: t('document.headings.policy_team'),
        data: [link_to(document.policy_team.name, document.policy_team)],
        classes: ["document-policy-team"]
      }
    end
    if document.respond_to?(:policy_advisory_groups) && document.policy_advisory_groups.any?
      metadata << {
        title: t('document.headings.advisory_groups'),
        data: array_of_links_to_policy_advisory_groups(document.policy_advisory_groups),
        classes: ["document-policy-advisory-groups"]
      }
    end
    if document.respond_to?(:part_of_series?) && document.part_of_series?
      metadata << {
        title: t('document.headings.document_series'),
        data: array_of_links_to_document_series(document),
        classes: ["document-document-series"]
      }
    end
    if document.respond_to?(:statistical_data_sets) && document.statistical_data_sets.any?
      metadata << {
        title: t('document.headings.live_data'),
        data: array_of_links_to_statistical_data_sets(document.published_statistical_data_sets),
        classes: ['document-statistical-data-sets']
      }
    end
    metadata
  end
end
