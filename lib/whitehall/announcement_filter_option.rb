module Whitehall
  class AnnouncementFilterOption
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :speech_types, :edition_types

    def slug
      label.downcase.gsub(/[^a-z]+/, "-")
    end

    def edition_types
      @edition_types || []
    end

    def self.find_by_slug(slug)
      all.find { |pt| pt.slug == slug }
    end

    NewsArticle = create(id: 1, label: "News article", edition_types: ["NewsArticle"])
    Speech = create(id: 2, label: "Speech", edition_types: ["Speech"], speech_types: SpeechType.non_statements)
    Statement = create(id: 3, label: "Statement", edition_types: ["Speech"], speech_types: SpeechType.statements)
    FatalityNotice = create(id: 4, label: "Fatality notice", edition_types: ["FatalityNotice"])
  end
end
