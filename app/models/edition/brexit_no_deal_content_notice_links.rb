module Edition::BrexitNoDealContentNoticeLinks
  extend ActiveSupport::Concern

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
end
