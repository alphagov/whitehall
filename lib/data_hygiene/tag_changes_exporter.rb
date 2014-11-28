class TagChangesExporter
  def initialize(csv_location, source_topic_id, destination_topic_id)
    @csv_location = csv_location
    @source_topic_id = source_topic_id
    @destination_topic_id = destination_topic_id
  end

  def export
    generate_csv_with_tag_changes
  end

private

  attr_reader :csv_location, :source_topic_id, :destination_topic_id

  def generate_csv_with_tag_changes
    CSV.open(csv_location, "wb") do |csv|
      csv << headers
      taggings.each { |tagging| csv << tagging }
    end
  end

  def tagged_to_topic
    Edition.joins(:specialist_sectors, :document).where(specialist_sectors: { tag: source_topic_id }).uniq
  end

  def headers
    %w(document_id document_type slug add_topic remove_topic)
  end

  def taggings
    tagged_to_topic.each_with_object([]) do |edition, result|
      result << [edition.document.id, edition.document.document_type, edition.slug, destination_topic_id, source_topic_id]
    end
  end
end
