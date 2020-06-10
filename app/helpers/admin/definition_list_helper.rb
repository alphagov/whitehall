module Admin::DefinitionListHelper
  def dd(value, default = nil)
    value = if value.present?
              if block_given?
                capture do
                  yield(value)
                end
              else
                value
              end
            else
              default || default_definition_list_value
            end
    tag.dd(value)
  end

  delegate :dt, to: :tag

  def definition(label, value, default = nil, &block)
    dt(label) + dd(value, default, &block)
  end

  def default_definition_list_value
    "<em>empty</em>".html_safe
  end
end
