module SyncChecker
  class TopicContentIdMap
    def self.fetch
      @content_id_map ||= Whitehall.publishing_api_v2_client
        .lookup_content_ids(
          base_paths: SpecialistSector.pluck(:tag).uniq.map { |tag| "/topic/#{tag}" }
        )
    end
  end
end
