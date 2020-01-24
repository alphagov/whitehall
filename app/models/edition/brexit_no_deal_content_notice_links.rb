module Edition::BrexitNoDealContentNoticeLinks
  extend ActiveSupport::Concern

  MAX_BREXIT_NO_DEAL_CONTENT_NOTICE_LINKS = 3

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.brexit_no_deal_content_notice_links.each do |link|
        edition.brexit_no_deal_content_notice_links.build(link.attributes.except("id"))
      end
    end
  end

  included do
    has_many :brexit_no_deal_content_notice_links, foreign_key: "edition_id", dependent: :destroy

    accepts_nested_attributes_for :brexit_no_deal_content_notice_links, allow_destroy: true, reject_if: :all_blank

    add_trait Trait
  end

  def allows_brexit_no_deal_content_notice?
    true
  end

  def build_no_deal_notice_links
    brexit_no_deal_content_notice_links_available_count.times do
      brexit_no_deal_content_notice_links.build
    end
  end

  def brexit_no_deal_content_notice_links_available_count
    MAX_BREXIT_NO_DEAL_CONTENT_NOTICE_LINKS - brexit_no_deal_content_notice_links_count
  end

  def brexit_no_deal_content_notice_links_count
    brexit_no_deal_content_notice_links.count do |link|
      link.persisted? || link.new_record?
    end
  end
end
