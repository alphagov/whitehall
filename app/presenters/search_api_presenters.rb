module SearchApiPresenters
  # Present content for the government search index
  def self.present_all_government_content
    Enumerator.new do |yielder|
      searchable_classes.each do |klass|
        klass.search_index.each do |search_index_entry|
          yielder << search_index_entry
        end
      end
    end
  end

  def self.searchable_classes
    [
      Organisation,
      TopicalEvent,
      OperationalField,
      PolicyGroup,
      StatisticsAnnouncement,
      WorldLocationNews,
    ]
  end
end
