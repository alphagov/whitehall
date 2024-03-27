module HasCorporateInformationPages
  extend ActiveSupport::Concern

  included do
    has_many :corporate_information_pages, through: "edition_#{table_name}".to_sym, source: :edition, class_name: "CorporateInformationPage"
    before_destroy do |record|
      record.corporate_information_pages.map(&:document).uniq.each(&:destroy)
    end
  end

  def summary
    about_us.summary if about_us.present?
  end

  def body
    about_us.body if about_us.present?
  end

  def corporate_information_page_types
    CorporateInformationPageType.all
  end

  def unused_corporate_information_page_types
    corporate_information_page_types - corporate_information_pages.map(&:corporate_information_page_type)
  end

  def build_corporate_information_page(params)
    # The standard corporate_info_pages.build method does not correctly set the
    # organisation|worldwide_organisation in the linking table.
    CorporateInformationPage.new(params.merge(self.class.name.underscore => self))
  end

  def published_corporate_information_pages
    corporate_information_pages.published
  end

  def about_us
    corporate_information_pages.published.for_slug("about")
  end

  def about_us_for(state:)
    corporate_information_pages.where(state:).for_slug("about")
  end
end
