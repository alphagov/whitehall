class AddSummaryAndBodyToWorldwideOrganisationTranslations < ActiveRecord::Migration[7.0]
  class Edition < ApplicationRecord
  end

  class CorporateInformationPage < Edition
    ABOUT_US_TYPE_ID = 20
    scope :published, -> { where(state: "published") }
    scope :draft, -> { where(state: "draft") }
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

    def draft_about_us
      @draft_about_us ||= corporate_information_pages.draft.find_by(
        corporate_information_page_type_id: CorporateInformationPage::ABOUT_US_TYPE_ID,
      )
    end
  end

  def up
    change_table :worldwide_organisation_translations, bulk: true do |t|
      t.column :summary, :text
      t.column :body, :text, size: :medium
    end

    number_of_worldwide_organisations = 0
    number_of_worldwide_organisations_without_about_page = 0
    number_of_worldwide_organisations_with_draft_content = 0
    number_of_worldwide_organisation_translations_created = 0

    WorldwideOrganisation.all.each do |worldwide_organisation|
      write "Copying content from WorldOrganisation: #{worldwide_organisation.slug}"
      number_of_worldwide_organisations += 1

      if worldwide_organisation.about_us.nil?
        write "  WorldOrganisation #{worldwide_organisation.slug} has no about page"
        number_of_worldwide_organisations_without_about_page += 1
        next
      end

      if worldwide_organisation.draft_about_us.present?
        write "  Draft content for WorldOrganisation #{worldwide_organisation.slug} exists but will not be copied"
        number_of_worldwide_organisations_with_draft_content += 1
      end

      worldwide_organisation.about_us.translations.each do |source_translation|
        write "  Processing #{source_translation.locale} translation from about page"
        target_translation = worldwide_organisation.translations.find_by(locale: source_translation.locale)
        if target_translation.nil?
          write "    Creating #{source_translation.locale} translation for WorldwideOrganisation; name attribute will not be set so rendered page will fallback to english name"
          number_of_worldwide_organisation_translations_created += 1
          target_translation = worldwide_organisation.translations.create!(locale: source_translation.locale)
        end
        write "    Copying content from about page to WorldwideOrganisation"
        target_translation.update!(summary: source_translation.summary, body: source_translation.body)
      end
    end

    write "Number of WorldwideOrganisations: #{number_of_worldwide_organisations}"
    write "Number of WorldwideOrganisations without an about page: #{number_of_worldwide_organisations_without_about_page}"
    write "Number of WorldwideOrganisations with draft content: #{number_of_worldwide_organisations_with_draft_content}"
    write "Number of WorldwideOrganisation translations created: #{number_of_worldwide_organisation_translations_created}"
  end

  def down
    change_table :worldwide_organisation_translations, bulk: true do |t|
      t.remove :summary
      t.remove :body
    end
  end
end
