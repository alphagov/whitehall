# Helper class to render govspeak from an edition outside of the view contexts.
module Whitehall
  class EditionGovspeakRenderer
    attr_accessor :edition

    def initialize(edition)
      @edition = edition
    end

    def body
      helpers.govspeak_edition_to_html(edition)
    end

    def unpublishing_explanation
      helpers.govspeak_to_html(edition.unpublishing.explanation) if edition.unpublishing.try(:explanation).present?
    end

  private

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
