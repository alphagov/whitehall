class TagChangesExporter
  def initialize(topic_id_to_add, topic_id_to_remove)
    @topic_id_to_add = topic_id_to_add
    @topic_id_to_remove = topic_id_to_remove
  end

  def export
    generate_csv_with_tag_changes
  end

private

  attr_reader :topic_id_to_add, :topic_id_to_remove

  def generate_csv_with_tag_changes
    CSV.open("test.csv", "wb") do |csv|
      csv << headers
      taggings.each { |tagging| csv << tagging }
    end
  end

  def tagged_to_topic
    Edition.published.joins(:specialist_sectors).where(specialist_sectors: { tag: topic_id_to_remove })
  end

  def headers
    %w(slug add_topic remove_topic)
  end

  def taggings
    tagged_to_topic.each_with_object([]) do |tagging, result|
      result << [tagging.slug, topic_id_to_add, tagging.primary_specialist_sector_tag]
    end
  end
end
