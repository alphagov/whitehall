module LeadImagePresenterHelper
  def lead_image_path
    if (images.first)
      images.first.url(:s300)
    else
      'placeholder.jpg'
    end
  end

  def lead_image_alt_text
    if (images.first)
      images.first.alt_text
    else
      'placeholder'
    end
  end

  def lead_image_caption
    if (images.first)
      caption = images.first.caption && images.first.caption.strip
      caption.present? && caption
    end
  end
end
