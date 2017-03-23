module SyncChecker
  class TopicContentIdMap
    def self.fetch
      @content_id_map ||= Services.publishing_api
        .lookup_content_ids(
          base_paths: SpecialistSector.pluck(:tag).uniq.map { |tag| "/topic/#{tag}" }
        )
    end
  end
end
