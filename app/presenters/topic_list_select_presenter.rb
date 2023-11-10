class TopicListSelectPresenter
  TAGGABLE_BRANCHES = ["welfare, money, business and industry, work, environment"].freeze

  def initialize(taxonomy_topic_email_override = nil)
    @taxonomy_topic_email_override = taxonomy_topic_email_override
  end

  attr_reader :taxonomy_topic_email_override

  def grouped_options(selected_taxon_content_id = nil)
    branches_sorted_by_level_one_taxon_name.map do |level_one_taxon|
      [level_one_taxon.name, sorted_transformed_subtopics(level_one_taxon, selected_taxon_content_id)]
    end
  end

  # def taxonomy_topic_email_override_hash
  #   topic_taxonomy.all_taxons.select { |taxon| taxon.content_id == taxonomy_topic_email_override }.first
  # end

private

  def branches_sorted_by_level_one_taxon_name
    topic_taxonomy.branches
    # .select { |branch| TAGGABLE_BRANCHES.include?(branch.name.downcase) }
    .sort_by { |branch| branch.name.downcase }
  end

  def sorted_transformed_subtopics(taxon, selected_taxon_content_id)
    transformed = transform_subtopics(taxon, selected_taxon_content_id)
    transformed.sort_by{ |s| s[:text]}
  end

  def transform_subtopics(taxon, selected_taxon_content_id)
    sorted_level_one_taxons(taxon).map do |child|
      transform_taxon(child, selected_taxon_content_id)
    end
  end

  def sorted_level_one_taxons(taxon)
    sorted_children = taxon.descendants.sort_by { |child| child.name.downcase }
    [taxon, sorted_children].flatten
  end

  def taxon_with_ancestors(taxon)
    case taxon.ancestors.count
    when 1
      "#{taxon.ancestors[0].name} > #{taxon.name} "
    when 2
      "#{taxon.ancestors[0].name} > #{taxon.ancestors[1].name} > #{taxon.name} "
    when 3
      "#{taxon.ancestors[0].name} > #{taxon.ancestors[1].name} > #{taxon.ancestors[2].name} > #{taxon.name} "
    when 4
      "#{taxon.ancestors[0].name} > #{taxon.ancestors[1].name} > #{taxon.ancestors[2].name} > #{taxon.ancestors[2].name} > #{taxon.name} "
    end
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
