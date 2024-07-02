require "test_helper"

class WorldwideOfficeTest < ActiveSupport::TestCase
  %w[contact edition worldwide_office_type].each do |param|
    test "should not be valid without a #{param}" do
      assert_not build(:worldwide_office, param.to_sym => nil).valid?
    end
  end

  test "delegates address-related methods to its contact" do
    contact = create(
      :contact_with_country,
      email: "email@email.com",
      contact_form_url: "http://contact.com/form",
      title: "Consulate General's Office",
      comments: "Totally bananas",
      recipient: "Eric",
      street_address: "29 Acacier Road",
      locality: "Dandytown",
      region: "Dandyville",
      postal_code: "D12 4CY",
      contact_numbers: [create(:contact_number)],
      country: create(:world_location, iso2: "GB"),
    )
    office = create(:worldwide_office, contact:)

    assert_equal contact.comments, office.comments
    assert_equal contact.contact_form_url, office.contact_form_url
    assert_equal contact.contact_numbers, office.contact_numbers
    assert_equal contact.contact_type_id, office.contact_type_id
    assert_equal contact.country, office.country
    assert_equal contact.country_code, office.country_code
    assert_equal contact.country_id, office.country_id
    assert_equal contact.country_name, office.country_name
    assert_equal contact.email, office.email
    assert_equal contact.has_postal_address?, office.has_postal_address?
    assert_equal contact.locality, office.locality
    assert_equal contact.postal_code, office.postal_code
    assert_equal contact.recipient, office.recipient
    assert_equal contact.region, office.region
    assert_equal contact.street_address, office.street_address
    assert_equal contact.title, office.title
  end

  test "sets a slug based on the title" do
    office = create(:worldwide_office, contact: create(:contact, title: "Consulate General's Office"))
    assert office.contact

    assert_equal "consulate-generals-office", office.slug
  end

  test "scopes the slug to the worldwide organisation" do
    office = create(:worldwide_office, contact: create(:contact, title: "Consulate General's Office"))
    office_at_same_org = create(:worldwide_office, edition: office.edition, contact: create(:contact, title: "Consulate General's Office"))

    assert_equal "consulate-generals-office", office.slug
    assert_equal "consulate-generals-office--2", office_at_same_org.slug

    office_at_different_org = create(:worldwide_office, contact: create(:contact, title: "Consulate General's Office"))
    assert_equal "consulate-generals-office", office_at_different_org.slug
  end

  test "is not translatable just yet" do
    assert_not WorldwideOffice.new.available_in_multiple_languages?
  end

  test "removes itself from any home page lists when it is destroyed" do
    office = create(:worldwide_office)
    list = create(:home_page_list)
    list.add_item(office)

    office.destroy!

    assert_not list.shown_on_home_page?(office)
  end

  test "republishes embassies index page on creation of worldwide office" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    contact = create(:contact)

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::EmbassiesIndexPresenter).twice

    Sidekiq::Testing.inline! do
      create(:worldwide_office, edition: worldwide_organisation, contact:)
    end
  end

  test "republishes embassies index page on update of worldwide office" do
    office = create(:worldwide_office)

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::EmbassiesIndexPresenter)

    Sidekiq::Testing.inline! do
      office.update!(slug: "new-slug")
    end
  end

  test "republishes embassies index page on deletion of worldwide office" do
    office = create(:worldwide_office)

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::EmbassiesIndexPresenter).twice

    Sidekiq::Testing.inline! do
      office.destroy!
    end
  end
end
