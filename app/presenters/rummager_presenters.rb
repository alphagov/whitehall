module RummagerPresenters
  # Present content for the government search index
  def self.present_all_government_content
    Enumerator.new do |yielder|
      searchable_classes_for_government_index.each do |klass|
        klass.search_index.each do |search_index_entry|
          yielder << search_index_entry
        end
      end
    end
  end

  # Present content for the detailed search index
  def self.present_all_detailed_content
    DetailedGuide.search_index
  end

  def self.searchable_classes_for_government_index
    searchable_classes - [DetailedGuide]
  end

  def self.searchable_classes
    [
      Organisation,
      TopicalEvent,
      OperationalField,
      PolicyGroup,
      TakePartPage,
      StatisticsAnnouncement,
      WorldLocation,
      WorldLocationNews,
      WorldwideOrganisation,
    ] + Whitehall.edition_classes
  end
end
