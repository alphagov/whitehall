module Reports
  class WorldwideOrganisationTranslationsReport
    CSV_HEADERS = [
      "Item",
      "Count",
      "---",
      "Worldwide organisation",
      "Translation",
      "Office",
      "Office has translation",
      "Contact has translation",
      "Corporate information page",
      "Corporate information page has translation",
      "Worldwide organisation has translation",
    ].freeze

    def report
      path = Rails.root.join("tmp/worldwide-organisation-translations_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      CSV.open(path, "wb", headers: CSV_HEADERS, write_headers: true) do |csv|
        worldwide_organisations_count(csv)
        worldwide_offices_count(csv)
        worldwide_corporate_information_pages_count(csv)

        organisations = WorldwideOrganisation.all.includes(:translations, offices: [contact: [:translations]])
        with_foreign_translations = organisations.select { |organisation| organisation.non_english_translations.present? }

        with_foreign_translations.each do |organisation|
          organisation.non_english_translations.each do |translation|
            organisation.offices.each do |office|
              csv << skip_columns(3) + [
                organisation.name,
                translation.locale,
                office.title,
                human_bool(false),
                human_bool(office.contact.translations.map(&:locale).include?(translation.locale)),
              ]
            end

            organisation.corporate_information_pages.where(state: :published).find_each do |page|
              csv << skip_columns(3) + [organisation.name, translation.locale] + skip_columns(3) + [
                page.title,
                human_bool(page.translations.map(&:locale).include?(translation.locale)),
              ] + skip_columns(1)

              page.non_english_translations&.each do |page_translation|
                organisation_has_translation = page.worldwide_organisation.translations.map(&:locale).include?(page_translation.locale)

                next if organisation_has_translation

                csv << skip_columns(3) + [organisation.name, page_translation.locale] + skip_columns(3) + [
                  page.title,
                  human_bool(true),
                  human_bool(false),
                ]
              end
            end
          end
        end
      end

      puts "Finished! Report available at #{path}"
    end

  private

    def worldwide_organisations_count(csv)
      csv << [
        "Number of worldwide organisations",
        WorldwideOrganisation.count,
      ]
    end

    def worldwide_offices_count(csv)
      csv << [
        "Number of worldwide offices",
        WorldwideOffice.count,
      ]
    end

    def worldwide_corporate_information_pages_count(csv)
      csv << [
        "Number of published worldwide corporate information pages",
        CorporateInformationPage.joins(:worldwide_organisation).where(state: :published).count,
      ]
    end

    def skip_columns(number)
      Array.new(number) { "" }
    end

    def human_bool(bool)
      bool ? "Yes" : "No"
    end
  end
end
