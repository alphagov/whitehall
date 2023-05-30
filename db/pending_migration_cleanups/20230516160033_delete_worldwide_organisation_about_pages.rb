class DeleteWorldwideOrganisationAboutPages < ActiveRecord::Migration[7.0]
  class Edition < ApplicationRecord
  end

  class Attachment < ApplicationRecord
    scope :not_deleted, -> { where(deleted: false) }

    def delete
      update_column(:deleted, true)
    end

    def destroy
      callbacks_result = transaction do
        run_callbacks(:destroy) do
          delete
        end
      end
      callbacks_result ? self : false
    end
  end

  class CorporateInformationPage < Edition
    ABOUT_US_TYPE_ID = 20

    has_many :attachments,
             -> { not_deleted.order("attachments.ordering, attachments.id") },
             as: :attachable,
             inverse_of: :attachable
  end

  class WorldwideOrganisation < ApplicationRecord
    has_many :edition_worldwide_organisations
    has_many :corporate_information_pages, through: :edition_worldwide_organisations, source: :edition, class_name: "::CorporateInformationPage"

    def about_us_page_editions
      corporate_information_pages.where(corporate_information_page_type_id: CorporateInformationPage::ABOUT_US_TYPE_ID)
    end
  end

  def up
    worldwide_organisations = WorldwideOrganisation.all
    about_us_pages = worldwide_organisations.flat_map(&:about_us_page_editions)
    about_us_pages_attachments = about_us_pages.flat_map(&:attachments)
    worldwide_organisations_count_before = worldwide_organisations.count
    about_us_pages_count_before = about_us_pages.count
    about_us_pages_attachments_count_before = about_us_pages_attachments.count

    WorldwideOrganisation.all.each do |worldwide_organisation|
      write "Processing #{worldwide_organisation.class} #{worldwide_organisation.id} - #{worldwide_organisation.slug}"
      worldwide_organisation.about_us_page_editions.each do |page|
        write "  Deleting #{page.class} #{page.id} - #{page.title}"
        page.attachments.each do |attachment|
          write "    Deleting #{attachment.class} #{attachment.id} - #{attachment.title}"
          attachment.destroy # rubocop:disable Rails/SaveBang
        end
        page.destroy!
      end
    end

    write "## Summary"
    write "### Before"
    write "WorldwideOrganisations: #{worldwide_organisations_count_before}"
    write "About Us Corporate Information Pages: #{about_us_pages_count_before}"
    write "Attachments: #{about_us_pages_attachments_count_before}"

    write "### After"
    worldwide_organisations = WorldwideOrganisation.all
    about_us_pages = worldwide_organisations.flat_map(&:about_us_page_editions)
    about_us_pages_attachments = about_us_pages.flat_map(&:attachments)
    write "WorldwideOrganisations: #{worldwide_organisations.count}"
    write "About Us Corporate Information Pages: #{about_us_pages.count}"
    write "Attachments: #{about_us_pages_attachments.count}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
