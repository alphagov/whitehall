class PromotionalFeatureItemPresenter < Draper::Base
  decorates :promotional_feature_item

  def css_classes
    ['feature', ('large' if double_width?)].compact.join(' ')
  end

  def image_url
    double_width? ? image.s630.url : image.s300.url
  end

  def display_image
    if model.title_url.blank?
      image_tag
    else
      h.link_to(image_tag, model.title_url)
    end
  end

  def image_tag
    h.image_tag(image_url, alt: image_alt_text)
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
    return if model.title.blank?

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
