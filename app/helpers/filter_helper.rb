module FilterHelper
  def organisation_options_for_statistics_announcement_filter(selected_slug = nil)
    options_for_select(Organisation.with_statistics_announcements.alphabetical.map { |org| [org.name, org.slug] }.unshift(["All departments", nil]), Array(selected_slug))
  end

  def topic_options_for_statistics_announcement_filter(content_id = nil)
    options_for_select(
      Taxonomy::TopicTaxonomy
        .new
        .ordered_taxons
        .map { |taxon| [taxon.name, taxon.content_id] }.unshift(["All topics", nil]),
      Array(content_id),
    )
  end

  def describe_filter(filter, base_url, opts = {})
    FilterDescriptionPresenter.new(filter, base_url, opts).render
  end
end
