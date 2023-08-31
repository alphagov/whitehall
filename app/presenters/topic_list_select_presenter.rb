class TopicListSelectPresenter
  def initialize(taxonomy_topic_email_override = nil)
    @taxonomy_topic_email_override = taxonomy_topic_email_override
  end

  attr_reader :taxonomy_topic_email_override

  def grouped_options(selected_taxon_content_id = nil)
    branches_sorted_by_level_one_taxon_name.map do |taxon|
      [taxon.name, subtopics(taxon.children, selected_taxon_content_id)]
    end
  end

private

  def subtopics(children, selected_taxon_content_id)
    children.map do |child|
      {
        text: child.name,
        value: child.content_id,
        selected: selected?(child.content_id, selected_taxon_content_id),
      }
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
