module Admin::FieldContainerHelper
  def field_container(id:, &block)
    content = capture(&block)
    content_tag(:div, content, id:)
  end
end
