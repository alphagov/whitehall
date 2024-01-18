class TopicListSelectPresenter
  # This presenter is used to select a taxonomy topic email override for some document collections
  #  We are only going to show the branches which the dept has told us they will need to tag to.
  TAGGABLE_BRANCHES = [
    "/business-and-industry",
    "/work",
    "/money",
    "/society-and-culture",
    "/environment",
    "/welfare",
  ].freeze

  def initialize(taxonomy_topic_email_override = nil)
    @taxonomy_topic_email_override = taxonomy_topic_email_override
  end

  attr_reader :taxonomy_topic_email_override

  def grouped_options(selected_taxon_content_id = nil)
    branches_sorted_by_level_one_taxon_name.map do |level_one_taxon|
      [level_one_taxon.name, sorted_transformed_descendants(level_one_taxon, selected_taxon_content_id)]
    end
  end

private

  def branches_sorted_by_level_one_taxon_name
    topic_taxonomy.visible_branches
    .select { |branch| TAGGABLE_BRANCHES.include?(branch.base_path) }
    .sort_by { |branch| branch.name.downcase }
  end

  def sorted_transformed_descendants(level_one_taxon, selected_taxon_content_id)
    transform_descendants(level_one_taxon, selected_taxon_content_id)
    .sort_by { |s| s[:text].downcase }
  end

  def transform_descendants(level_one_taxon, selected_taxon_content_id)
    sort_descendants(level_one_taxon).map do |child|
      transform_taxon(child, selected_taxon_content_id)
    end
  end

  def sort_descendants(level_one_taxon)
    sorted_descendants = level_one_taxon.descendants.sort_by { |descendant| descendant.name.downcase }
    [level_one_taxon, sorted_descendants].flatten
  end

  def taxon_with_ancestors(taxon)
    ancestors_names = taxon.ancestors.map(&:name)
    ancestor_string = ancestors_names.join(" > ")

    "#{ancestor_string} > #{taxon.name} " if ancestors_names.any?
  end

  def transform_taxon(taxon, selected_taxon_content_id = nil)
    formatted_taxon_name =
      taxon.ancestors.present? ? taxon_with_ancestors(taxon) : taxon.name.to_s
    {
      text: formatted_taxon_name,
      value: taxon.content_id,
      selected: selected?(taxon.content_id, selected_taxon_content_id),
    }
  end

  def selected?(content_id, selected_taxon_content_id)
    previously_selected = selected_taxon_content_id || taxonomy_topic_email_override
    previously_selected == content_id
  end

  def topic_taxonomy
    @topic_taxonomy ||= Taxonomy::TopicTaxonomy.new
  end
end
