module Whitehall
  class AnnouncementFilterOption
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :speech_types, :edition_types, :news_article_types

    def slug
      label.downcase.gsub(/[^a-z]+/, "-")
    end

    def edition_types
      @edition_types || []
    end

    def self.find_by_slug(slug)
      all.find { |pt| pt.slug == slug }
    end

    PressRelease = create(id: 1, label: "Press releases", edition_types: ["NewsArticle"], news_article_types: [NewsArticleType::PressRelease, NewsArticleType::Unknown])
    NewsStory = create(id: 2, label: "News stories", edition_types: ["NewsArticle"], news_article_types: [NewsArticleType::NewsStory, NewsArticleType::Unknown])
    FatalityNotice = create(id: 3, label: "Fatality notices", edition_types: ["FatalityNotice"])
    Speech = create(id: 4, label: "Speeches", edition_types: ["Speech"], speech_types: SpeechType.non_statements)
    Statement = create(id: 5, label: "Statements", edition_types: ["Speech"], speech_types: SpeechType.statements)
    Rebuttal = create(id: 6, label: "Rebuttals", edition_types: ["NewsArticle"], news_article_types: [NewsArticleType::Rebuttal])
  end
end
