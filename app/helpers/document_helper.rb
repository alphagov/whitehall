module DocumentHelper
  include ApplicationHelper
  include CountryHelper
  include DocumentCollectionHelper
  include MinisterialRolesHelper
  include PolicyHelper
  include PolicyGroupsHelper
  include RoleAppointmentsHelper
  include TopicsHelper
  include TranslationHelper

  def edition_page_title(edition)
    edition.withdrawn? ? "[Withdrawn] #{edition.title}" : edition.title
  end

  def document_block_counter
    @block_count ||= 0
    @block_count += 1
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
        image_tag 'national-statistics.png', alt: t('national_statistics.heading'), class: 'national-statistics-logo'
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
    data_sets.map { |data_set| link_to data_set.title, public_document_path(data_set), class: 'statistical-data-set-link' }
  end

  MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document"
  MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet"
  MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation"

  def file_abbr_tag(abbr, title)
    content_tag(:abbr, abbr, title: title)
  end

  def humanized_content_type(file_extension)
    file_extension_vs_humanized_content_type = {
      "chm"  => file_abbr_tag('CHM', 'Microsoft Compiled HTML Help'),
      "csv"  => file_abbr_tag('CSV', 'Comma-separated Values'),
      "diff" => file_abbr_tag('DIFF', 'Plain text differences'),
      "doc"  => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
      "docx" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
      "dot"  => file_abbr_tag('DOT', 'MS Word Document Template'),
      "dxf"  => file_abbr_tag('DXF', 'AutoCAD Drawing Exchange Format'),
      "eps"  => file_abbr_tag('EPS', 'Encapsulated PostScript'),
      "gif"  => file_abbr_tag('GIF', 'Graphics Interchange Format'),
      "gml"  => file_abbr_tag('GML', 'Geography Markup Language'),
      "html" => file_abbr_tag('HTML', 'Hypertext Markup Language'),
      "ics" => file_abbr_tag('ICS', 'iCalendar file'),
      "jpg"  => "JPEG",
      "odp"  => file_abbr_tag('ODP', 'OpenDocument Presentation'),
      "ods"  => file_abbr_tag('ODS', 'OpenDocument Spreadsheet'),
      "odt"  => file_abbr_tag('ODT', 'OpenDocument Text document'),
      "pdf"  => file_abbr_tag('PDF', 'Portable Document Format'),
      "png"  => file_abbr_tag('PNG', 'Portable Network Graphic'),
      "ppt"  => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
      "pptx" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
      "ps"   => file_abbr_tag('PS', 'PostScript'),
      "rdf"  => file_abbr_tag('RDF', 'Resource Description Framework'),
      "rtf"  => file_abbr_tag('RTF', 'Rich Text Format'),
      "sch"  => file_abbr_tag('SCH', 'XML based Schematic'),
      "txt"  => "Plain text",
      "wsdl" => file_abbr_tag('WSDL', 'Web Services Description Language'),
      "xls"  => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
      "xlsm" => file_abbr_tag('XSLM', 'MS Excel Macro-Enabled Workbook'),
      "xlsx" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
      "xlt"  => file_abbr_tag('XLT', 'MS Excel Spreadsheet Template'),
      "xsd"  => file_abbr_tag('XSD', 'XML Schema'),
      "xslt" => file_abbr_tag('XSLT', 'Extensible Stylesheet Language Transformation'),
      "zip"  => file_abbr_tag('ZIP', 'Zip archive'),
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
      image_tag(attachment.file.thumbnail.url, alt: '')
    elsif attachment.html?
      image_tag('pub-cover-html.png', alt: '')
    elsif %w{doc docx odt}.include? attachment.file_extension
      image_tag('pub-cover-doc.png', alt: '')
    elsif %w{xls xlsx ods csv}.include? attachment.file_extension
      image_tag('pub-cover-spreadsheet.png', alt: '')
    else
      image_tag('pub-cover.png', alt: '')
    end
  end

  def alternative_format_order_link(attachment, alternative_format_contact_email)
    attachment_info = []
    attachment_info << "  Title: #{attachment.title}"
    attachment_info << "  Original format: #{attachment.file_extension}"
    attachment_info << "  ISBN: #{attachment.isbn}" if attachment.isbn.present?
    attachment_info << "  Unique reference: #{attachment.unique_reference}" if attachment.unique_reference.present?
    attachment_info << "  Command paper number: #{attachment.command_paper_number}" if attachment.command_paper_number.present?
    if attachment.hoc_paper_number.present?
      attachment_info << "  House of Commons paper number: #{attachment.hoc_paper_number}"
      attachment_info << "  Parliamentary session: #{attachment.parliamentary_session}"
    end

    mail_to alternative_format_contact_email, alternative_format_contact_email,
      subject: "Request for '#{attachment.title}' in an alternative format",
      body: %(Details of document required:

#{attachment_info.join("\n")}

Please tell us:

  1. What makes this format unsuitable for you?
  2. What format you would prefer?
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
    if attachment.html?
      attributes << content_tag(:span, 'HTML', class: 'type')
    elsif attachment.external?
      attributes << content_tag(:span, attachment.url, class: 'url')
    else
      attributes << content_tag(:span, humanized_content_type(attachment.file_extension), class: 'type')
      attributes << content_tag(:span, number_to_human_size(attachment.file_size), class: 'file-size')
      attributes << content_tag(:span, pluralize(attachment.number_of_pages, "page") , class: 'page-length') if attachment.number_of_pages.present?
    end
    attributes.join(', ').html_safe
  end

  def native_language_name_for(locale)
    Locale.new(locale).native_language_name
  end

  def link_to_translation(locale)
    link_to native_language_name_for(locale), locale: locale
  end

  def part_of_metadata(document, policies = [], sector_tag_finder = nil)
    part_of = []

    if document.respond_to?(:part_of_published_collection?) && document.part_of_published_collection?
      part_of += array_of_links_to_document_collections(document)
    end

    if document.respond_to?(:statistical_data_sets) && document.statistical_data_sets.any?
      part_of += array_of_links_to_statistical_data_sets(document.published_statistical_data_sets)
    end

    if document.respond_to?(:topical_events) && document.topical_events.any?
      part_of += array_of_links_to_topical_events(document.topical_events)
    end

    if sector_tag_finder && (tagged_topics = sector_tag_finder.topics).any?
      links_to_topics = tagged_topics.map do |topic|
        link_to topic.title, topic.web_url, class: 'sector-link'
      end
      part_of += links_to_topics
    end

    if policies.any?
      part_of += array_of_links_to_policies(policies)
    end

    if document.respond_to?(:world_locations) && document.world_locations.any?
      part_of += array_of_links_to_world_locations(document.world_locations)
    end

    part_of
  end

  def from_metadata(document, links_only = false)
    from = []

    if document.lead_organisations.any?
      from += array_of_links_to_organisations(document.lead_organisations)
    end

    if !(document.respond_to?(:statistics?) && document.statistics?)
      if document.respond_to?(:delivered_by_minister?)
        if document.person_override?
          from << document.person_override if not links_only
        else
          from << link_to_person(document.role_appointment.person)
        end
      end
    end

    if document.respond_to?(:role_appointments) && document.role_appointments.any?
      from += array_of_links_to_role_appointments(document.role_appointments)
    end

    if document.respond_to?(:worldwide_organisations) && document.worldwide_organisations.any?
      from += array_of_links_to_worldwide_organisations(document.worldwide_organisations)
    end

    if document.respond_to?(:policy_groups) && document.policy_groups.any?
      from += array_of_links_to_policy_groups(document.policy_groups)
    end

    if (other_organisations = document.sorted_organisations - document.lead_organisations).any?
      from += array_of_links_to_organisations(other_organisations)
    end

    from
  end

  def political_state_analytics_tag(edition)
    tag :meta,
      name: 'govuk:political-status',
      content: political_state_analytics_value(edition)
  end

  def political_state_analytics_value(edition)
    return 'non-political' unless edition.political?
    edition.historic? ? 'historic' : 'political'
  end

  def publishing_government_analytics_tag(edition)
    return unless edition.government
    tag :meta,
      name: 'govuk:publishing-government',
      content: edition.government.slug
  end
end
