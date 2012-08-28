class NewsArticle < Edition
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Countries

  def has_summary?
    true
  end

  def lead_image
    images.first
  end
end
