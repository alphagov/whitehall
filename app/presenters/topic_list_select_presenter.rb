class TopicListSelectPresenter
  def initialize(taxonomy_topic_email_override = nil)
    @taxonomy_topic_email_override = taxonomy_topic_email_override
  end

  attr_reader :taxonomy_topic_email_override

  def grouped_options(selected_taxon_content_id = nil)
    branches_sorted_by_level_one_taxon_name.map do |level_one_taxon|
      [level_one_taxon.name, subtopics(level_one_taxon, selected_taxon_content_id)]
    end
  end

  def transform_taxon(taxon, selected_taxon_content_id = nil)
    {
      text: taxon.name,
      value: taxon.content_id,
      selected: selected?(taxon.content_id, selected_taxon_content_id )
    }
  end

private

  def subtopics(taxon, selected_taxon_content_id)
    taxon.taxon_list.map do |child|
      transform_taxon(child, selected_taxon_content_id)
    end
  end

  def branches_sorted_by_level_one_taxon_name
    topic_taxonomy.branches.sort_by { |taxon| taxon.name.downcase }
  end

  def selected?(content_id, selected_taxon_content_id)
    previously_selected = selected_taxon_content_id || taxonomy_topic_email_override
    previously_selected == content_id
  end

  def topic_taxonomy
    @topic_taxonomy ||= Taxonomy::TopicTaxonomy.new
  end
end
