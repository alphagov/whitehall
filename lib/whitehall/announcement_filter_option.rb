module Whitehall
  class AnnouncementFilterOption < FilterOption
    attr_accessor :speech_types, :news_article_types

    PressRelease = create(id: 1, label: "Press releases", search_format_types: [NewsArticleType::PressRelease.search_format_types, NewsArticleType::Unknown.search_format_types].flatten, edition_types: ["NewsArticle"], news_article_types: [NewsArticleType::PressRelease, NewsArticleType::Unknown])
    NewsStory = create(id: 2, label: "News stories", search_format_types: [NewsArticleType::NewsStory.search_format_types, NewsArticleType::Unknown.search_format_types].flatten, edition_types: ["NewsArticle"], news_article_types: [NewsArticleType::NewsStory, NewsArticleType::Unknown])
    FatalityNotice = create(id: 3, label: "Fatality notices", search_format_types: [FatalityNotice.search_format_type], edition_types: ["FatalityNotice"])
    Speech = create(id: 4, label: "Speeches", search_format_types: [SpeechType.non_statements.map(&:search_format_types)].flatten, edition_types: ["Speech"], speech_types: SpeechType.non_statements)
    Statement = create(id: 5, label: "Statements", search_format_types: [SpeechType.statements.map(&:search_format_types)].flatten, edition_types: ["Speech"], speech_types: SpeechType.statements)
    GovernmentResponse = create(id: 6, label: "Government responses", search_format_types: NewsArticleType::GovernmentResponse.search_format_types, edition_types: ["NewsArticle"], news_article_types: [NewsArticleType::GovernmentResponse])
  end
end
