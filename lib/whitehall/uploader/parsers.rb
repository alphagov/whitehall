module Whitehall
  module Uploader
    module Parsers
      autoload :DateParser, 'whitehall/uploader/parsers/date_parser'
      autoload :RelativeToAbsoluteLinks, 'whitehall/uploader/parsers/relative_to_absolute_links'
      autoload :SummariseBody, 'whitehall/uploader/parsers/summarise_body'
    end
  end
end
