Topic.transaction do
  topic_slugs = Topic.all.map { |t| [t.name.parameterize, t.slug] }
  discrepancies = topic_slugs.select { |a, b| a != b }
  puts "Topic discrepancies before: #{discrepancies.count}, #{discrepancies.inspect}"

  Topic.find_each do |topic|
    topic.remove_from_search_index
    def topic.should_generate_new_friendly_id?
      true
    end
    topic.save!
  end

  topic_slugs = Topic.all.map { |t| [t.name.parameterize, t.slug] }
  discrepancies = topic_slugs.select { |a, b| a != b }
  puts "Topic discrepancies after: #{discrepancies.count}, #{discrepancies.inspect}"

  raise ActiveRecord::Rollback if discrepancies.any?
end
