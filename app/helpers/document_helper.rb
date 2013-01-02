module DocumentHelper
  def published_or_updated(edition)
    edition.first_published_version? ? 'published' : 'updated'
  end

  def edition_organisation_class(edition)
    if organisation = edition.organisations.first
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
    if document.respond_to?(:nation_inapplicabilities) and document.nation_inapplicabilities.any?
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

  def list_of_links_to_statistical_data_sets(data_sets)
    data_sets.map { |data_set| link_to data_set.title, public_document_path(data_set) }.to_sentence.html_safe
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
      "pptx" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE
    }
    file_extension_vs_humanized_content_type[file_extension.downcase] if file_extension.present?
  end

  def attachment_reference(attachment)
    ref = []
    ref << "ISBN "+ content_tag(:span, attachment.isbn, class: "isbn") if attachment.isbn.present?
    ref << content_tag(:span, attachment.unique_reference, class: "unique_reference") if attachment.unique_reference.present?
    ref << content_tag(:span, attachment.command_paper_number, class: "command_paper_number") if attachment.command_paper_number.present?

    ref.join(', ').html_safe
  end

  def attachment_thumbnail(attachment)
    if attachment.pdf?
      image_tag(attachment.url(:thumbnail), alt: "")
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
    mail_to alternative_format_contact_email, alternative_format_contact_email,
      subject: "Request for '#{attachment.title}' in an alternative format",
      body: %Q[

Details of document required:

#{attachment_info.join("\n")}
      ]
  end

  def attachment_references(attachment)
    references = []
    references << "ISBN: #{attachment.isbn}" if attachment.isbn.present?
    references << "Unique reference: #{attachment.unique_reference}" if attachment.unique_reference.present?
    references << "Command paper number: #{attachment.command_paper_number}" if attachment.command_paper_number.present?
    prefix = references.size == 1 ? "and its reference" : "and its references"
    references.any? ? ", #{prefix} (" + references.join(", ") + ")" : ""
  end
end
