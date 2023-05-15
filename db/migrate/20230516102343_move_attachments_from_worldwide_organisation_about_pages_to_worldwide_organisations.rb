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
    WorldwideOrganisation.all.each do |worldwide_organisation|
      next if worldwide_organisation.about_us.nil?

      worldwide_organisation.about_us.attachments.each do |attachment|
        attachment.update!(attachable: worldwide_organisation)
      end
    end
  end

  def down
    # intentionally left blank
  end
end
