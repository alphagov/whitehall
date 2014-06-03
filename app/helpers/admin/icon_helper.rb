module Admin::IconHelper

  def icon(label)
    css_classes = icon_css_classes_for_label(label)
    "<i class='#{css_classes.join(' ')}'></i> #{h(label)}".html_safe
  end

  def icon_css_classes_for_label(label)
    case label.downcase
    when "delete", "remove" then %w(icon-trash icon-white)
    when "add" then %w(icon-plus icon-white)
    else
      ["icon-#{label.downcase}"]
    end
  end
end
