module ConfigurableContentBlocks
  module Renderable
    def render_in(view_context)
      view_context.render template: "admin/configurable_content_blocks/_#{template_name}", locals: { block: self }
    end

  private

    def template_name
      raise NotImplementedError
    end
  end
end
