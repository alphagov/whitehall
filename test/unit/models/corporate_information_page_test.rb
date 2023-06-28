require "test_helper"

class CorporateInformationPageTest < ActiveSupport::TestCase
  test "creating a new corporate information page republishes the owning organisation" do
    test_object = create(:organisation)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    create(:corporate_information_page, organisation: test_object)
  end

  test "updating an existing corporate information page republishes the owning organisation" do
    test_object = create(:organisation)
    corporate_information_page = create(:corporate_information_page, organisation: test_object)
    corporate_information_page.external = true
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    corporate_information_page.save!
  end

  test "deleting a corporate information page republishes the owning organisation" do
    test_object = create(:organisation)
    corporate_information_page = create(:corporate_information_page, organisation: test_object)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    corporate_information_page.destroy!
  end

  test "corporate information pages cannot be previously published" do
    assert_not build(:corporate_information_page).previously_published
  end

  test "base_path is nil when neither organisation or worldwide organisation is present" do
    corporate_information_page = create(:corporate_information_page, organisation: nil, worldwide_organisation: nil)
    assert_nil corporate_information_page.base_path
  end

  test "base_path appends the Corporate Information Page path to the associated Organisation base_path" do
    organisation = create(:organisation)
    corporate_information_page = create(
      :corporate_information_page,
      organisation:,
    )

    assert_equal "/government/organisations/#{organisation.name}/about/#{corporate_information_page.slug}", corporate_information_page.base_path
  end

  test "base_path appends /about to the associated Organisation base_path when about page" do
    organisation = create(:organisation)
    corporate_information_page = create(
      :about_corporate_information_page,
      organisation:,
    )

    assert_equal "/government/organisations/#{organisation.name}/about", corporate_information_page.base_path
  end

  test "base_path appends Corporate Information Page path to the associated WorldwideOrganisation base_path" do
    worldwide_organisation = create(:worldwide_organisation)
    corporate_information_page = create(
      :corporate_information_page,
      organisation: nil,
      worldwide_organisation:,
    )

    assert_equal "/world/organisations/#{worldwide_organisation.name}/about/#{corporate_information_page.slug}", corporate_information_page.base_path
  end

  test "#base_path appends /about/about to WorldwideOrganisation base_path when about page" do
    worldwide_organisation = create(:worldwide_organisation)
    corporate_information_page = create(
      :about_corporate_information_page,
      organisation: nil,
      worldwide_organisation:,
    )

    assert_equal "/world/organisations/#{worldwide_organisation.name}/about/about", corporate_information_page.base_path
  end

  test "republishes owning organisation after commit when present" do
    organisation = create(:organisation)
    corporate_information_page = create(:corporate_information_page, organisation:, worldwide_organisation: nil)

    Whitehall::PublishingApi.expects(:republish_async).with(organisation).once

    corporate_information_page.update!(body: "new body")
  end

  test "republishes owning worldwide organisation after commit when present" do
    worldwide_organisation = create(:worldwide_organisation)
    corporate_information_page = create(:corporate_information_page, organisation: nil, worldwide_organisation:)

    Whitehall::PublishingApi.expects(:republish_async).with(worldwide_organisation).once

    corporate_information_page.update!(body: "new body")
  end

  test "does not republish owning organisation when absent" do
    corporate_information_page = create(:corporate_information_page, organisation: nil, worldwide_organisation: nil)

    Whitehall::PublishingApi.expects(:republish_async).never

    corporate_information_page.update!(body: "new body")
  end
end
