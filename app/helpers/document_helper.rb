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
end
