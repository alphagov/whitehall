class ConvertCorporateInformationPagesToEditions < ActiveRecord::Migration
  class ::OldCorporateInformationPage < ActiveRecord::Base
    translates :summary, :body, foreign_key: :corporate_information_page_id
    belongs_to :organisation, polymorphic: true
    has_many :attachments, as: :attachable, order: 'attachments.ordering, attachments.id'
    delegate :slug, :display_type_key, to: :type
    def type
      CorporateInformationPageType.find_by_id(type_id)
    end
    def title
      type.title(organisation)
    end
    # Need a name classmethod so that has_many query (eg attachments) uses
    # correct type to find existing items.
    def self.name
      'CorporateInformationPage'
    end

  end
  OldCorporateInformationPage.table_name = 'corporate_information_pages'
  OldCorporateInformationPage::Translation.table_name = 'corporate_information_page_translations'
  Whitehall.skip_safe_html_validation = true

  def up
    converter = DataHygiene::ConvertCorporateInformationPages.new
    transaction do
      OldCorporateInformationPage.includes(:organisation).find_each do |old_cip|
        converter.convert old_cip
      end
    end
  end

  def down
    Document.where(document_type: "CorporateInformationPage").find_each do |doc|
      doc.attachments.destroy_all
      doc.destroy
    end
  end
end
