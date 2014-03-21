class ConvertCorporateInformationPagesToEditions < ActiveRecord::Migration
  class ::OldCorporateInformationPage < ActiveRecord::Base
    translates :summary, :body, foreign_key: :corporate_information_page_id
    belongs_to :organisation, polymorphic: true
    has_many :attachments, as: :attachable, order: 'attachments.ordering, attachments.id', source_type: "CorporateInformationPage"
    delegate :slug, :display_type_key, to: :type
    def type
      CorporateInformationPageType.find_by_id(type_id)
    end
    def title
      type.title(organisation)
    end

  end
  OldCorporateInformationPage.table_name = 'corporate_information_pages'
  OldCorporateInformationPage::Translation.table_name = 'corporate_information_page_translations'
  Whitehall.skip_safe_html_validation = true

  # default title text for validation only.
  CorporateInformationPage.class_eval do
    def title
      "title"
    end
  end
  def up

    gds_ig_team_user = User.find_by_name!('GDS Inside Government Team')
    transaction do
      OldCorporateInformationPage.includes(:organisation).each do |old_cip|
        org = old_cip.organisation
        puts "Migrating #{org.name}: #{old_cip.slug} (#{old_cip.id})"
        doc = Document.create!(document_type: 'CorporateInformationPage',
                               #slug: "#{org.slug}:#{old_cip.slug}",
                               created_at: old_cip.created_at,
                               updated_at: old_cip.updated_at)
        new_cip = CorporateInformationPage.create!(
          created_at: old_cip.created_at,
          updated_at: old_cip.updated_at,
          lock_version: old_cip.lock_version,
          document_id: doc.id,
          creator: gds_ig_team_user,
          title: old_cip.title,
          summary: old_cip.summary.present? ? old_cip.summary : ".",
          body: old_cip.body,
          corporate_information_page_type_id: old_cip.type_id,
          major_change_published_at: old_cip.updated_at,
          state: 'published')
        if org.is_a? Organisation
          EditionOrganisation.create!(
            edition: new_cip,
            organisation: org,
            lead: true,
            lead_ordering: 1)
        else
          new_cip.worldwide_organisations << org
        end
        old_cip.translations.each do |old_trans|
          Edition::Translation.create!(
            edition_id: new_cip.id,
            locale: old_trans.locale,
            title: old_cip.title, # OH NOES NO TITLE IN OLD TRANS
            summary: old_trans.summary.present? ? old_trans.summary : ".",
            body: old_trans.body,
            updated_at: old_trans.updated_at,
            created_at: old_trans.created_at) unless old_trans.locale == :en
        end
        Attachment.where(
          attachable_type: 'CorporateInformationPage',
          attachable_id: old_cip.id
        ).update_all(attachable_type: 'Edition', attachable_id: new_cip.id)

      end
    end
  end

  def down
  end
end
