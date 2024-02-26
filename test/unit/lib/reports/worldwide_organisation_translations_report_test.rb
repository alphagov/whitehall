require "test_helper"

class Reports::WorldwideOrganisationTranslationsReportTest < ActiveSupport::TestCase
  test "returns a report containing counts of worldwide organisation translations" do
    create(:worldwide_organisation, :with_main_office, :with_corporate_information_pages)

    Timecop.freeze do
      path = Rails.root.join("tmp/worldwide-organisation-translations_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      capture_io do
        Reports::WorldwideOrganisationTranslationsReport.new.report
      end

      assert_equal "Item", CSV.read(path)[0][0]
      assert_equal "Count", CSV.read(path)[0][1]

      assert_equal "Number of worldwide organisations", CSV.read(path)[1][0]
      assert_equal "1", CSV.read(path)[1][1]

      assert_equal "Number of worldwide offices", CSV.read(path)[2][0]
      assert_equal "1", CSV.read(path)[2][1]

      assert_equal "Number of published worldwide corporate information pages", CSV.read(path)[3][0]
      assert_equal "6", CSV.read(path)[3][1]

      File.delete(path)
    end
  end

  test "returns a report containing worldwide offices and their translations" do
    office_with_translated_contact = build(:worldwide_office, worldwide_organisation: nil, contact: create(:contact, translated_into: [:es]))
    office_with_english_contact = build(:worldwide_office, worldwide_organisation: nil, contact: create(:contact))
    create(:worldwide_organisation, name: "Worldwide organisation name", translated_into: [:es], offices: [office_with_translated_contact, office_with_english_contact])

    Timecop.freeze do
      path = Rails.root.join("tmp/worldwide-organisation-translations_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      capture_io do
        Reports::WorldwideOrganisationTranslationsReport.new.report
      end

      csv = CSV.read(path)

      assert_equal "Worldwide organisation", csv[0][3]
      assert_equal "Worldwide organisation name", csv[4][3]
      assert_equal "Worldwide organisation name", csv[5][3]
      assert_equal "Worldwide organisation name", csv[6][3]
      assert_equal "Worldwide organisation name", csv[7][3]

      assert_equal "Translation", csv[0][4]
      assert_equal "en", csv[4][4]
      assert_equal "en", csv[5][4]
      assert_equal "es", csv[6][4]
      assert_equal "es", csv[7][4]

      assert_equal "Office", csv[0][5]
      assert_equal "Contact description", csv[4][5]
      assert_equal "Contact description", csv[5][5]
      assert_equal "Contact description", csv[6][5]
      assert_equal "Contact description", csv[7][5]

      assert_equal "Office has translation", csv[0][6]
      assert_equal "Yes", csv[4][6]
      assert_equal "Yes", csv[5][6]
      assert_equal "No", csv[6][6] # Offices (access and opening times) cannot be translated currently
      assert_equal "No", csv[7][6] # Offices (access and opening times) cannot be translated currently

      assert_equal "Contact has translation", csv[0][7]
      assert_equal "Yes", csv[4][7]
      assert_equal "Yes", csv[5][7]
      assert_equal "Yes", csv[6][7]
      assert_equal "No", csv[7][7]

      File.delete(path)
    end
  end

  test "returns a report containing published corporate information pages and their translations" do
    corporate_information_page_with_translation = build(:published_corporate_information_page, translated_into: [:es])
    corporate_information_page_with_other_translation = build(:published_corporate_information_page, translated_into: [:fr], corporate_information_page_type: CorporateInformationPageType::OurGovernance)
    corporate_information_page_without_translation = build(:personal_information_charter_corporate_information_page)
    corporate_information_page_draft = build(:draft_corporate_information_page, corporate_information_page_type: CorporateInformationPageType::WelshLanguageScheme)
    create(:worldwide_organisation, name: "Worldwide organisation name", translated_into: [:es], corporate_information_pages: [corporate_information_page_with_translation, corporate_information_page_without_translation, corporate_information_page_draft, corporate_information_page_with_other_translation])

    Timecop.freeze do
      path = Rails.root.join("tmp/worldwide-organisation-translations_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      capture_io do
        Reports::WorldwideOrganisationTranslationsReport.new.report
      end

      csv = CSV.read(path)

      assert_not_includes csv.flatten, "Welsh language scheme"

      assert_equal "Worldwide organisation", csv[0][3]
      assert_equal "Worldwide organisation name", csv[4][3]
      assert_equal "Worldwide organisation name", csv[5][3]
      assert_equal "Worldwide organisation name", csv[6][3]
      assert_equal "Worldwide organisation name", csv[7][3]
      assert_equal "Worldwide organisation name", csv[8][3]
      assert_equal "Worldwide organisation name", csv[9][3]
      assert_equal "Worldwide organisation name", csv[10][3]

      assert_equal "Translation", csv[0][4]
      assert_equal "en", csv[4][4]
      assert_equal "en", csv[5][4]
      assert_equal "en", csv[6][4]
      assert_equal "fr", csv[7][4]
      assert_equal "es", csv[8][4]
      assert_equal "es", csv[9][4]
      assert_equal "es", csv[10][4]

      assert_equal "Corporate information page", csv[0][8]
      assert_equal "publication-scheme", csv[4][8]
      assert_equal "personal-information-charter", csv[5][8]
      assert_equal "our-governance", csv[6][8]
      assert_equal "our-governance", csv[7][8]
      assert_equal "publication-scheme", csv[8][8]
      assert_equal "personal-information-charter", csv[9][8]
      assert_equal "our-governance", csv[10][8]

      assert_equal "Corporate information page has translation", csv[0][9]
      assert_equal "Yes", csv[4][9]
      assert_equal "Yes", csv[5][9]
      assert_equal "Yes", csv[6][9]
      assert_equal "Yes", csv[7][9]
      assert_equal "Yes", csv[8][9]
      assert_equal "No", csv[9][9]
      assert_equal "No", csv[10][9]

      assert_equal "Worldwide organisation has translation", csv[0][10]
      assert_equal "", csv[4][10]
      assert_equal "", csv[5][10]
      assert_equal "", csv[6][10]
      assert_equal "No", csv[7][10]
      assert_equal "", csv[8][10]
      assert_equal "", csv[9][10]
      assert_equal "", csv[10][10]

      File.delete(path)
    end
  end
end
