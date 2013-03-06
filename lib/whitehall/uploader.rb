module Whitehall
  module Uploader
    autoload :Csv, 'whitehall/uploader/csv'
    autoload :Finders, 'whitehall/uploader/finders'
    autoload :Parsers, 'whitehall/uploader/parsers'
    autoload :Builders, 'whitehall/uploader/builders'
    autoload :HeadingValidator, 'whitehall/uploader/heading_validator'
    autoload :Row, 'whitehall/uploader/row'

    autoload :ConsultationRow, 'whitehall/uploader/consultation_row'
    autoload :DetailedGuideRow, 'whitehall/uploader/detailed_guide_row'
    autoload :NewsArticleRow, 'whitehall/uploader/news_article_row'
    autoload :PublicationRow, 'whitehall/uploader/publication_row'
    autoload :SpeechRow, 'whitehall/uploader/speech_row'
    autoload :StatisticalDataSetRow, 'whitehall/uploader/statistical_data_set_row'
  end
end
