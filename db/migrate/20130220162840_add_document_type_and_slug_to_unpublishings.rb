class AddDocumentTypeAndSlugToUnpublishings < ActiveRecord::Migration
  class Unpublishing < ActiveRecord::Base; end

  def up
    add_column :unpublishings, :document_type, :string
    add_column :unpublishings, :slug, :string

    unpublishing_slug_fixes = {
      96932 => ['StatisticalDataSet', 'mix-adjusted-prices'],
      101951 => ['DetailedGuide', 'case-programme'],
      70963 => ['Publication', 'national-resilience-extranet-documents'],
      88475 => ['Publication', 'capital-for-enterprise-ltd-government-procurement-card-spend-over-500-for-2012-to-2013'],
      96932 => ['StatisticalDataSet', 'mix-adjusted-prices'],
      96937 => ['StatisticalDataSet', 'live-tables-on-house-price-index'],
      96882 => ['NewsArticle', 'welcome-to-the-new-home-on-the-web-for-the-office-of-the-advocate-general'],
    }

    unpublishing_slug_fixes.each do |edition_id, (document_type, slug)|
      unpublishing = Unpublishing.find_by_edition_id(edition_id)
      if unpublishing
        unpublishing.update_attributes(document_type: document_type, slug: slug)
      end
    end
  end

  def down
    remove_column :unpublishings, :document_type
    remove_column :unpublishings, :slug
  end
end