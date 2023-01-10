class PromotionalFeatureItemPresenter < Whitehall::Decorators::Decorator
  delegate_instance_methods_of PromotionalFeatureItem

  def image_url
    image.s300.url
  end

  def display_image
    return "" if image_tag.blank?

    if model.title_url.blank?
      image_tag
    else
      context.link_to(image_tag, model.title_url)
    end
  end

  def image_tag
    return "" if image_url.blank?

    context.image_tag(image_url, alt: image_alt_text)
  end

  def width
    1
  end

  def summary
    context.tag.p context.format_with_html_line_breaks(model.summary)
  end

  def title
    return if model.title.blank?

    if model.title_url.blank?
      context.tag.h3(model.title)
    else
      context.tag.h3(title_link)
    end
  end

  def title_link
    context.link_to(model.title, model.title_url, ({ rel: "external" } if context.is_external?(model.title_url)))
  end
end
