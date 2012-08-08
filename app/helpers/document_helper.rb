module DocumentHelper
  def published_or_updated(edition)
    edition.first_edition? ? 'published' : 'updated'
  end

  def edition_thumbnail_tag(edition)
    image_url = edition.has_thumbnail? ? edition.thumbnail_url : 'pub-cover.png'
    link_to image_tag(image_url), public_document_path(edition)
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
      image_tag "/government/assets/national-statistics.png", alt: "National Statistic"
    end
  end

  def only_applies_to_nations_paragraph(document)
    if document.respond_to?(:nation_inapplicabilities) and document.nation_inapplicabilities.any?
      content_tag :p, "Only applies to #{document.applicable_nations.map(&:name).sort.to_sentence}#{see_alternative_urls_for_inapplicable_nations(document)}.".html_safe, class: 'inapplicable-nations'
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

  MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document"
  MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet"
  MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation"

  def humanized_content_type(file_extension)
    file_extension_vs_humanized_content_type = {
      "pdf" => content_tag(:abbr, 'PDF', title: 'Portable Document Format'),
      "csv" => content_tag(:abbr, 'CSV', title: 'Comma-separated Values'),
      "rtf" => content_tag(:abbr, 'RTF', title: 'Rich Text Format'),
      "png" => content_tag(:abbr, 'PNG', title: 'Portable Network Graphic'),
      "jpg" => "JPEG",
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
end
