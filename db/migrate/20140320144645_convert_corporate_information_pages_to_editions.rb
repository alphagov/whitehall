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
                               created_at: old_cip.created_at,
                               updated_at: old_cip.updated_at)
        new_cip = CorporateInformationPage.create!(
          created_at: old_cip.created_at,
          updated_at: old_cip.updated_at,
          lock_version: old_cip.lock_version,
          document_id: doc.id,
          creator: gds_ig_team_user,
          title: old_cip.title,
          summary: old_cip.summary,
          body: old_cip.body,
          corporate_information_page_type_id: old_cip.type_id,
          major_change_published_at: old_cip.updated_at,
          state: 'published')
        if org.is_a? Organisation
          EditionOrganisation.create!(
            edition: new_cip,
            organisation: org
          )
        else
          new_cip.worldwide_organisations << org
        end
        old_cip.translations.each do |old_trans|
          unless old_trans.locale == :en
            new_cip.translations.create!(
              locale: old_trans.locale,
              summary: old_trans.summary,
              body: old_trans.body,
              title: old_cip.title
            )
          end
        end
        old_cip.attachments.each do |old_att|
          # Create new Attachments, but keep existing attachment_data instances.
          new_cip.attachments.create!(
            title: old_cip.title,
            accessible: old_cip.accessible,
            isbn: old_cip.isbn,
            unique_reference: old_cip.unique_reference,
            command_paper_number: old_cip.command_paper_number,
            order_url: old_cip.url,
            price_in_pence: old_cip.price_in_pence,
            attachment_data_id: old_cip.attachment_data_id,
            ordering: old_cip.ordering,
            hoc_paper_number: old_cip.hoc_paper_number,
            parliamentary_session: old_cip.hoc_parliamentary_session,
            unnumbered_command_paper: old_cip.unnumbered_command_paper,
            unnumbered_hoc_paper: old_cip.unnumbered_hoc_paper,
            type: old_cip.type,
            slug: old_cip.slug,
            body: old_cip.body,
            manually_numbered_headings: old_cip.manually_numbered_headings,
            locale: old_cip.locale
          )
        end
      end
    end
  end

  def down
  end
end
