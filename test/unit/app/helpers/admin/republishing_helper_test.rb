require "test_helper"

class Admin::RepublishingHelperTest < ActionView::TestCase
  test "#republishable_content_types returns a sorted list combining valid document types and other publishable content types" do
    # we need to eager load here to ensure we have all the models
    Rails.application.eager_load!

    feature_flags.switch! :editionable_worldwide_organisations, true

    expected_content_types = [
      omnipresent_content_types,
      content_types[:editionable_worldwide_organisations_enabled],
    ].flatten.sort
    result_minus_test_types = republishable_content_types.reject { |type| content_types[:test_specific].include? type }

    assert_equal expected_content_types, result_minus_test_types
  end

  test "#republishable_content_types excludes `EditionableWorldwideOrganisation` when the editionable_worldwide_organisations feature flag is disabled" do
    # we need to eager load here to ensure we have all the models
    Rails.application.eager_load!

    feature_flags.switch! :editionable_worldwide_organisations, false

    expected_content_types = omnipresent_content_types.sort
    result_minus_test_types = republishable_content_types.reject { |type| content_types[:test_specific].include? type }

    assert_equal expected_content_types, result_minus_test_types
  end

  test "#non_editionable_content_types returns a list of non-editionable content types" do
    # we need to eager load here to ensure we have all the models
    Rails.application.eager_load!

    assert_equal content_types[:omnipresent_non_editionable], non_editionable_content_types.sort
  end

  test "#republishing_index_bulk_republishing_rows capitalises the first letter of the bulk content type" do
    first_bulk_content_type = republishing_index_bulk_republishing_rows.first.first[:text]

    assert_equal first_bulk_content_type, "All documents"
  end

  test "#republishing_index_bulk_republishing_rows creates a link to the confirmation page for content types that don't require extra input" do
    all_documents_link = republishing_index_bulk_republishing_rows.flatten.find { |column|
      column[:text].include?('Republish <span class="govuk-visually-hidden">all documents</span>')
    }[:text]

    expected_link = '<a id="all-documents" class="govuk-link" href="/government/admin/republishing/bulk/all-documents/confirm">Republish <span class="govuk-visually-hidden">all documents</span></a>'

    assert_equal expected_link, all_documents_link
  end

  test "#republishing_index_bulk_republishing_rows creates a link to the new page for content types that require extra input" do
    all_by_type_link = republishing_index_bulk_republishing_rows.flatten.find { |column|
      column[:text].include?('Republish <span class="govuk-visually-hidden">all by type</span>')
    }[:text]

    expected_link = '<a id="all-by-type" class="govuk-link" href="/government/admin/republishing/bulk/by-type/new">Republish <span class="govuk-visually-hidden">all by type</span></a>'

    assert_equal expected_link, all_by_type_link
  end

  test "#republishable_content_types_select_options creates select options from republishable_content_types" do
    # we need to eager load here to ensure we have all the models
    Rails.application.eager_load!

    options = republishable_content_types_select_options

    assert_includes options, {
      text: "CallForEvidence",
      value: "call-for-evidence",
    }

    assert_includes options, {
      text: "Contact",
      value: "contact",
    }
  end
end

def omnipresent_content_types
  content_types[:omnipresent_editionable].concat(content_types[:omnipresent_non_editionable])
end

def content_types
  { omnipresent_editionable: %w[CallForEvidence
                                CaseStudy
                                Consultation
                                CorporateInformationPage
                                DetailedGuide
                                DocumentCollection
                                FatalityNotice
                                NewsArticle
                                Publication
                                Speech
                                StatisticalDataSet],
    omnipresent_non_editionable: %w[Contact
                                    Government
                                    HistoricalAccount
                                    OperationalField
                                    Organisation
                                    Person
                                    PolicyGroup
                                    Role
                                    RoleAppointment
                                    StatisticsAnnouncement
                                    TakePartPage
                                    TopicalEvent
                                    TopicalEventAboutPage
                                    WorldLocationNews
                                    WorldwideOffice
                                    WorldwideOrganisation],
    test_specific: %w[GenericEdition
                      SearchableEdition
                      Edition::AlternativeFormatProviderTest::EditionWithAlternativeFormat
                      Edition::AppointmentTest::EditionWithAppointment
                      Edition::EditionableWorldwideOrganisationTest::EditionWithWorldwideOrganisations
                      Edition::ImagesTest::EditionWithImages
                      Edition::StatisticalDataSetsTest::EditionWithStatisticalDataSets
                      Edition::LimitedAccessTest::LimitedByDefaultEdition],
    editionable_worldwide_organisations_enabled: "EditionableWorldwideOrganisation" }
end
