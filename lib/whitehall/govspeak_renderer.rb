# Helper class to render govspeak outside of the view contexts.
module Whitehall
  class GovspeakRenderer < ActionController::Renderer
    delegate :govspeak_edition_to_html,
             :govspeak_to_html,
             :govspeak_with_attachments_to_html,
             :govspeak_html_attachment_to_html,
             :block_attachments,
             to: :helpers

    # Override the parent's initialize method so that
    # we can set the desired defaults.
    def initialize
      super(ApplicationController, {}, DEFAULTS.dup)
    end

  private

    # We can't use `render` directly as `block_attachments` needs
    # to return an array so construct a helpers proxy that allows
    # us to call the govspeak helpers directly. This implementation
    # mirrors that of `render` but we return the helpers proxy
    # instead of rendering a template.
    def helpers
      @helpers ||= begin
        request = ActionDispatch::Request.new @env
        request.routes = controller._routes

        instance = controller.new
        instance.set_request!(request)
        instance.set_response!(controller.make_response!(request))
        instance.helpers
      end
    end
  end
end
