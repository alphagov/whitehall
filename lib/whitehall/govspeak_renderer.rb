# Helper class to render govspeak outside of the view contexts.
module Whitehall
  class GovspeakRenderer
    delegate :govspeak_edition_to_html, :govspeak_to_html, to: :helpers

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
