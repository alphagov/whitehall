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

  def list_of_links_to_inapplicable_nations(edition)
    edition.nation_inapplicabilities.map { |i| link_to_inapplicable_nation(i) }.to_sentence.html_safe
  end

  def link_to_inapplicable_nation(nation_inapplicability)
    if nation_inapplicability.alternative_url.present?
      link_to nation_inapplicability.nation.name, nation_inapplicability.alternative_url, class: "country", rel: "external"
    else
      nation_inapplicability.nation.name
    end
  end
end
