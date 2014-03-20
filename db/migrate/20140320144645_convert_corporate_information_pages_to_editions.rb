class ConvertCorporateInformationPagesToEditions < ActiveRecord::Migration
  class ::OldCorporateInformationPage < ActiveRecord::Base
    translates :summary, :body, foreign_key: :corporate_information_page_id
    belongs_to :organisation, polymorphic: true
    has_many :attachments, as: :attachable, order: 'attachments.ordering, attachments.id', inverse_of: :attachable
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
  #OldCorporateInformationPage.translation_options[:foreign_key] = "corporate_information_page_id"
  def up

    # Remove validation of translated attributes for now.
    #old_validators = CorporateInformationPage.validators.dup
    #CorporateInformationPage.validators = old_validators.reject {|v| v.class == ActiveModel::Validations::PresenceValidator && !(v.attributes & [:summary, :body, :title]).empty?}
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
          #published_major_version: old_cip.updated_at,
          #published_minor_version: old_cip.updated_at,
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
        old_cip.attachments.each do |att|
          att.attachable_type = 'Edition'
          att.attachable_id = new_cip.id
          att.save
        end

      end
    end
    #CorporateInformationPageType.validators = old_validators
  end

  def down
  end
end
