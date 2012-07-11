class NewsArticle < Edition
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Countries
  include Edition::Featurable

  def has_summary?
    true
  end

  def lead_image
    images.first
  end
end
