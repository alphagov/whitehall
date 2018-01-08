module Admin::IconHelper
  def icon(label)
    css_classes = icon_css_classes_for_label(label)
    "<i class='#{css_classes.join(' ')}'></i> #{h(label)}".html_safe
  end

  def icon_css_classes_for_label(label)
    case label.downcase
    when "delete", "remove" then ['glyphicon-trash', 'glyphicon']
    when "add" then ['glyphicon-plus', 'glyphicon']
    else
      ["glyphicon glyphicon-#{label.downcase}"]
    end
  end
end
