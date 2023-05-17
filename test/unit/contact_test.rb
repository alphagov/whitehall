require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "should be invalid without a description" do
    contact = build(:contact, title: nil)
    assert_not contact.valid?
  end

  test "should be invalid if contact_form_url is invalid" do
    contact = build(:contact, contact_form_url: "not.a.url")
    assert_not contact.valid?
  end

  test "should be invalid without a contact_type" do
    contact = build(:contact, contact_type: nil)
    assert_not contact.valid?
  end

  test "should be valid with no postal address fields" do
    contact = build(
      :contact,
      recipient: "",
      street_address: "",
      locality: "",
      region: "",
      postal_code: "",
      country_id: "",
    )
    assert contact.valid?
  end

  test "should be invalid with only country but no street address" do
    country = create(:world_location)
    contact = build(
      :contact,
      recipient: "",
      street_address: "",
      locality: "",
      region: "",
      postal_code: "",
      country_id: country.id,
    )
    assert_not contact.valid?
    assert_equal ["can't be blank"], contact.errors[:street_address]
  end

  test "should be invalid with only street address but no country" do
    contact = build(
      :contact,
      recipient: "",
      street_address: "123 Acacia Avenue",
      locality: "",
      region: "",
      postal_code: "",
      country_id: "",
    )
    assert_not contact.valid?
    assert_equal ["can't be blank"], contact.errors[:country_id]
  end

  test "should be valid with only street address and country" do
    country = create(:world_location)
    contact = build(
      :contact,
      recipient: "",
      street_address: "123 Acacia avenue",
      locality: "",
      region: "",
      postal_code: "",
      country_id: country.id,
    )
    assert contact.valid?
  end

  test "should return a country code" do
    contact = build(:contact, country: build(:world_location, iso2: "GB"))
    assert_equal "GB", contact.country_code
  end

  test "should return a country name" do
    contact = build(:contact, country: build(:world_location, name: "United Kingdom"))
    assert_equal "United Kingdom", contact.country_name
  end

  test "should allow creation of nested contact numbers" do
    contact = create(:contact, contact_numbers_attributes: [{ label: "Telephone", number: "123" }])
    assert_equal 1, contact.contact_numbers.count
    assert_equal "Telephone", contact.contact_numbers[0].label
    assert_equal "123", contact.contact_numbers[0].number
  end

  test "should not create nested contact numbers if their attributes are blank" do
    contact = create(:contact, contact_numbers_attributes: [{ label: "", number: "" }])
    assert_equal 0, contact.contact_numbers.count
  end

  test "should destroy associated contact numbers on destruction" do
    contact = create(:contact, contact_numbers: [create(:contact_number)])
    contact.destroy!
    assert contact.contact_numbers.empty?
  end

  test "removes itself from any home page lists when it is destroyed" do
    contact = create(:contact)
    list = create(:home_page_list)
    list.add_item(contact)

    contact.destroy!

    assert_not list.shown_on_home_page?(contact)
  end

  test "#missing_translations should only include contactable translations" do
    organisation = create(:organisation, translated_into: %i[de es fr])
    contact = create(:contact, contactable: organisation, translated_into: [:es])

    expected_locales = %i[de fr].map { |l| Locale.new(l) }
    assert_equal expected_locales, contact.missing_translations
  end

  test "republishes dependent editions after update" do
    Sidekiq::Testing.inline! do
      contact = create(:contact)
      news_article = create(:published_news_article, body: "For more information, get in touch at: [Contact:#{contact.id}]")
      corp_info_page = create(:published_corporate_information_page, body: "For free advice, please visit our office: [Contact:#{contact.id}]")
      ServiceListeners::EditionDependenciesPopulator.new(news_article).populate!
      ServiceListeners::EditionDependenciesPopulator.new(corp_info_page).populate!

      PresentPageToPublishingApi.any_instance.stubs(:publish).with(PublishingApi::EmbassiesIndexPresenter)
      expect_publishing(contact)
      expect_republishing(news_article, corp_info_page)

      contact.update!(title: "Changed contact title")
    end
  end

  test "creating a new contact republishes the organisation" do
    test_object = create(:organisation)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    create(:contact, contactable: test_object)
  end

  test "deleting a contact republishes the organisation" do
    test_object = create(:organisation)
    contact = create(:contact, contactable: test_object)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    contact.destroy!
  end

  test "updating a contact republishes dependent policy groups" do
    contact = create(:contact)
    policy_group = create(
      :policy_group,
      description: "Some text with a single contact: [Contact:#{contact.id}]",
    )

    Whitehall::PublishingApi.expects(:republish_async).with(policy_group).once

    contact.update!(title: "A new name")
  end

  test "republishes embassies index page on creation of contact" do
    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::EmbassiesIndexPresenter)

    create(:contact)
  end

  test "republishes embassies index page on update of contact" do
    contact = create(:contact_with_country)

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::EmbassiesIndexPresenter)

    contact.update!(locality: "new-locality")
  end

  test "republishes embassies index page on deletion of contact" do
    contact = create(:contact)

    PresentPageToPublishingApi.any_instance.expects(:publish).with(PublishingApi::EmbassiesIndexPresenter)

    contact.destroy!
  end

  test "republishes worldwide office on creation of related contact" do
    worldwide_office = create(:worldwide_office)

    Whitehall::PublishingApi.expects(:republish_async).with(worldwide_office).once

    create(:contact, contactable: worldwide_office)
  end

  test "republishes worldwide office on update of related contact" do
    worldwide_office = create(:worldwide_office)

    Whitehall::PublishingApi.expects(:republish_async).with(worldwide_office).once

    worldwide_office.contact.update!(locality: "new-locality")
  end

  test "republishes worldwide office on deletion of related contact" do
    worldwide_office = create(:worldwide_office)

    Whitehall::PublishingApi.expects(:republish_async).with(worldwide_office).once

    worldwide_office.contact.destroy!
  end
end
