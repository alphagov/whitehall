module Whitehall
  class AbbreviationExtractor
    def initialize(edition)
      @edition = edition
    end

    def extract
      abbr_tags
        .map { |abbr_tag|
          {
            terms: [
              abbr_tag.attr("title"),
              abbr_tag.inner_text,
            ],
            type: "abbreviation",
          }
        }
        .uniq
    end

  private

    def abbr_tags
      Nokogiri::HTML(edition_html).css("abbr")
    end

    def edition_html
      helpers.govspeak_to_html(
        @edition.body,
        [],
        heading_numbering: :manual,
        contact_heading_tag: "h4",
      )
    end

    def helpers
      @helpers ||= ApplicationController.new.helpers
    end
  end
end
