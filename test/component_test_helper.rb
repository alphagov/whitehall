require "test_helper"

class ComponentTestCase < ActionView::TestCase
  helper Rails.application.helpers

  def component_name
    raise NotImplementedError, "Override this method in your test class"
  end

  def render_component(locals)
    render partial: "components/#{component_name}", locals:
  end
end
