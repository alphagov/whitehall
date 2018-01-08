module Govspeak
  class DependableEditionsExtractor
    include EmbeddedContentPatterns

    def initialize(govspeak)
      @govspeak = govspeak
    end

    def editions
      return [] if @govspeak.blank?
      editions = []
      { ADMIN_EDITION_PATH => 0,
        ADMIN_ORGANISATION_CIP_PATH => 1,
        ADMIN_WORLDWIDE_ORGANISATION_CIP_PATH => 1,}.each do |regex, capture_index|
        @govspeak.scan(regex).map do |capture|
          editions << Edition.in_pre_publication_state.find_by(id: capture[capture_index])
        end
      end
      editions.compact.uniq
    end
  end
end
