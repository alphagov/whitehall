module Whitehall
  class AbbreviationExtractor
    def initialize(edition)
      @edition = edition
    end

    def extract
      abbr_tags.map do |abbr_tag|
        {
          terms: [
            abbr_tag.attr('title'),
            abbr_tag.inner_text
          ],
          type: "abbreviation"
        }
      end.uniq
    end

  private

    def abbr_tags
      Nokogiri::HTML(edition_html).css("abbr")
    end

    def edition_html
      helpers.govspeak_to_html(
        @edition.body,
        [],
        { heading_numbering: :manual, contact_heading_tag: 'h4' }
      )
    end

    # Because the govspeak helpers in whitehall rely on rendering partials, we
    # need to make sure the view paths are set, otherwise the helpers can't find
    # the partials.
    def helpers
      @helpers ||= begin
        helpers = ApplicationController.helpers
        helpers.view_paths = ApplicationController.view_paths
        helpers
      end
    end
  end
end
