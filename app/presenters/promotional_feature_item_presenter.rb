class PromotionalFeatureItemPresenter < Draper::Base
  decorates :promotional_feature_item

  def css_classes
    'large' if double_width?
  end

  def image_url
    double_width? ? image.s630.url : image.s300.url
  end

  def link_list_class
    'dash-list' unless double_width?
  end

  def width
    double_width? ? 2 : 1
  end

  def summary
    h.content_tag :p, h.format_with_html_line_breaks(model.summary)
  end

  def title
    return unless model.title

    if model.title_url.blank?
      h.content_tag(:h3, model.title)
    else
      h.content_tag(:h3, title_link)
    end
  end

  def title_link
    h.link_to(model.title, model.title_url, ({rel: 'external'} if h.is_external?(model.title_url)))
  end
end
