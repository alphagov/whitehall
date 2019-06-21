# Helper class to render govspeak outside of the view contexts.
module Whitehall
  class GovspeakRenderer
    delegate :govspeak_edition_to_html,
             :govspeak_to_html,
             :govspeak_with_attachments_to_html,
             :html_attachment_govspeak_headers_html,
             :block_attachments,
             to: :view_context

  private

    # Because the govspeak helpers in whitehall rely on rendering partials, we
    # need to make sure the view paths are set, otherwise the helpers can't find
    # the partials.
    def view_context
      @view_context ||= begin
        view_context = ActionView::Base.new
        ApplicationController.modules_for_helpers([:all]).each do |mod|
          view_context.extend mod
        end
        view_context.view_paths = ApplicationController.view_paths
        view_context
      end
    end
  end
end
