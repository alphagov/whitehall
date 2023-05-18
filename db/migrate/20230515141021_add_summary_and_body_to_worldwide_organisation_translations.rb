class AddSummaryAndBodyToWorldwideOrganisationTranslations < ActiveRecord::Migration[7.0]
  class Edition < ApplicationRecord
  end

  class CorporateInformationPage < Edition
    ABOUT_US_TYPE_ID = 20
    scope :published, -> { where(state: "published") }
    translates :summary, :body
  end

  class WorldwideOrganisation < ApplicationRecord
    has_many :edition_worldwide_organisations
    has_many :corporate_information_pages, through: :edition_worldwide_organisations, source: :edition, class_name: "::CorporateInformationPage"
    translates :summary, :body

    def about_us
      @about_us ||= corporate_information_pages.published.find_by(
        corporate_information_page_type_id: CorporateInformationPage::ABOUT_US_TYPE_ID,
      )
    end
  end

  def up
    change_table :worldwide_organisation_translations, bulk: true do |t|
      t.column :summary, :text
      t.column :body, :text, size: :medium
    end

    WorldwideOrganisation.all.each do |worldwide_organisation|
      next if worldwide_organisation.about_us.nil?

      worldwide_organisation.about_us.translations.each do |source_translation|
        target_translation = worldwide_organisation.translations.find_by(locale: source_translation.locale)
        if target_translation.nil?
          target_translation = worldwide_organisation.translations.create!(locale: source_translation.locale)
        end
        target_translation.update!(summary: source_translation.summary, body: source_translation.body)
      end
    end
  end

  def down
    change_table :worldwide_organisation_translations, bulk: true do |t|
      t.remove :summary
      t.remove :body
    end
  end
end
