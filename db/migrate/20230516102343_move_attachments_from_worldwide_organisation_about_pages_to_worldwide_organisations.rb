class MoveAttachmentsFromWorldwideOrganisationAboutPagesToWorldwideOrganisations < ActiveRecord::Migration[7.0]
  class Attachment < ApplicationRecord
    belongs_to :attachable, polymorphic: true
  end

  class Edition < ApplicationRecord
  end

  class CorporateInformationPage < Edition
    ABOUT_US_TYPE_ID = 20
    has_many :attachments, as: :attachable, inverse_of: :attachable
    scope :published, -> { where(state: "published") }
  end

  class WorldwideOrganisation < ApplicationRecord
    has_many :edition_worldwide_organisations
    has_many :corporate_information_pages, through: :edition_worldwide_organisations, source: :edition, class_name: "::CorporateInformationPage"
    has_many :attachments, as: :attachable, inverse_of: :attachable

    def about_us
      @about_us ||= corporate_information_pages.published.find_by(
        corporate_information_page_type_id: CorporateInformationPage::ABOUT_US_TYPE_ID,
      )
    end
  end

  def up
    number_of_worldwide_organisations = 0
    number_of_attachments = 0

    WorldwideOrganisation.all.each do |worldwide_organisation|
      write "Moving attachments for WorldOrganisation: #{worldwide_organisation.slug}"
      number_of_worldwide_organisations += 1

      if worldwide_organisation.about_us.nil?
        write "  WorldOrganisation #{worldwide_organisation.slug} has no about page"
        next
      end

      worldwide_organisation.about_us.attachments.each do |attachment|
        write "  Processing attachment: #{attachment.id}"
        number_of_attachments += 1
        attachment.update!(attachable: worldwide_organisation)
      end
    end

    write "Number of WorldwideOrganisations: #{number_of_worldwide_organisations}"
    write "Number of Attachments moved: #{number_of_attachments}"
  end

  def down
    # intentionally left blank
  end
end
