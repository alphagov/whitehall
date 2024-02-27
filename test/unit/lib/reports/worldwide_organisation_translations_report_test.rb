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

      assert_equal "Translation", csv[0][4]
      assert_equal "es", csv[4][4]
      assert_equal "es", csv[5][4]

      assert_equal "Office", csv[0][5]
      assert_equal "Contact description", csv[4][5]
      assert_equal "Contact description", csv[5][5]

      assert_equal "Office has translation", csv[0][6]
      assert_equal "No", csv[4][6] # Offices (access and opening times) cannot be translated currently
      assert_equal "No", csv[5][6] # Offices (access and opening times) cannot be translated currently

      assert_equal "Contact has translation", csv[0][7]
      assert_equal "Yes", csv[4][7]
      assert_equal "No", csv[5][7]

      File.delete(path)
    end
  end

  test "returns a report containing published corporate information pages and their translations" do
    corporate_information_page_with_translation = build(:published_corporate_information_page, translated_into: [:es])
    corporate_information_page_without_translation = build(:personal_information_charter_corporate_information_page)
    corporate_information_page_draft = build(:draft_corporate_information_page, corporate_information_page_type: CorporateInformationPageType::WelshLanguageScheme)
    create(:worldwide_organisation, name: "Worldwide organisation name", translated_into: [:es], corporate_information_pages: [corporate_information_page_with_translation, corporate_information_page_without_translation, corporate_information_page_draft])

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

      assert_equal "Translation", csv[0][4]
      assert_equal "es", csv[4][4]
      assert_equal "es", csv[5][4]

      assert_equal "Corporate information page", csv[0][8]
      assert_equal "Publication scheme", csv[4][8]
      assert_equal "Personal information charter", csv[5][8]

      assert_equal "Corporate information page has translation", csv[0][9]
      assert_equal "Yes", csv[4][9]
      assert_equal "No", csv[5][9]

      File.delete(path)
    end
  end
end
