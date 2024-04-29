require "test_helper"

class EditionableWorldwideOrganisationTest < ActiveSupport::TestCase
  test "can be associated with one or more worldwide offices" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    worldwide_office = create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation)

    assert_equal [worldwide_office], worldwide_organisation.offices
  end

  test "can have a default news article image" do
    image = build(:featured_image_data)
    worldwide_organisation = build(:editionable_worldwide_organisation, default_news_image: image)
    assert_equal image, worldwide_organisation.default_news_image
  end

  test "republishes news articles after commit when using default news image" do
    worldwide_organisation = create(:published_editionable_worldwide_organisation, :with_default_news_image)
    news_article = create(:news_article_world_news_story, :published, editionable_worldwide_organisations: [worldwide_organisation])
    draft_news_article = create(:news_article_world_news_story, :draft, editionable_worldwide_organisations: [worldwide_organisation])
    other_organisation_news_article = create(:news_article_world_news_story, :draft, editionable_worldwide_organisations: [create(:published_editionable_worldwide_organisation, :with_default_news_image)])
    news_article_with_image = create(:news_article_world_news_story, images: [create(:image)], editionable_worldwide_organisations: [worldwide_organisation])

    Whitehall::PublishingApi.expects(:republish_document_async).with(news_article.document).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(draft_news_article.document).once
    Whitehall::PublishingApi.expects(:republish_document_async).with(other_organisation_news_article.document).never
    Whitehall::PublishingApi.expects(:republish_document_async).with(news_article_with_image.document).never

    worldwide_organisation.create_draft(create(:writer))
  end

  test "destroys associated worldwide offices" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    worldwide_office = create(:worldwide_office)
    worldwide_organisation.offices << worldwide_office

    worldwide_organisation.destroy!

    assert_equal 0, worldwide_organisation.offices.count
  end

  test "should be be valid without taxons" do
    worldwide_organisation = build(:draft_editionable_worldwide_organisation)
    assert worldwide_organisation.valid?
  end

  test "should set an analytics identifier on create" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    assert_equal "WO#{worldwide_organisation.id}", worldwide_organisation.analytics_identifier
  end

  test "an ambassadorial role is a primary role and not a secondary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    ambassador_role = create(:ambassador_role, :occupied)
    worldwide_organisation.roles << ambassador_role

    assert_equal ambassador_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a high commissioner role is a primary role and not a secondary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    high_commissioner_role = create(:high_commissioner_role, :occupied)
    worldwide_organisation.roles << high_commissioner_role

    assert_equal high_commissioner_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a governor role is a primary role and not a secondary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.primary_role

    governor_role = create(:governor_role, :occupied)
    worldwide_organisation.roles << governor_role

    assert_equal governor_role, worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "a deputy head of mission is second in charge and not a primary one" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.secondary_role

    deputy_role = create(:deputy_head_of_mission_role, :occupied)
    worldwide_organisation.roles << deputy_role

    assert_equal deputy_role, worldwide_organisation.secondary_role
    assert_nil worldwide_organisation.primary_role
  end

  test "office_staff_roles returns worldwide office staff roles" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_equal [], worldwide_organisation.office_staff_roles

    staff_role1 = create(:worldwide_office_staff_role, :occupied)
    staff_role2 = create(:worldwide_office_staff_role, :occupied)
    worldwide_organisation.roles << staff_role1
    worldwide_organisation.roles << staff_role2

    assert_equal [staff_role1, staff_role2], worldwide_organisation.office_staff_roles
    assert_nil worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
  end

  test "primary, secondary and office staff roles return occupied roles only" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    worldwide_organisation.roles << create(:ambassador_role, :vacant)
    worldwide_organisation.roles << create(:deputy_head_of_mission_role, :vacant)
    worldwide_organisation.roles << create(:worldwide_office_staff_role, :vacant)

    assert_nil worldwide_organisation.primary_role
    assert_nil worldwide_organisation.secondary_role
    assert_equal [], worldwide_organisation.office_staff_roles

    a = create(:ambassador_role, :occupied)
    b = create(:deputy_head_of_mission_role, :occupied)
    c = create(:worldwide_office_staff_role, :occupied)
    worldwide_organisation.roles << a
    worldwide_organisation.roles << b
    worldwide_organisation.roles << c

    assert_equal a, worldwide_organisation.primary_role
    assert_equal b, worldwide_organisation.secondary_role
    assert_equal [c], worldwide_organisation.office_staff_roles
  end

  test "should clone social media associations and their translations when new draft of published edition is created" do
    published_worldwide_organisation = create(
      :editionable_worldwide_organisation,
      :published,
      :with_social_media_account,
      translated_into: [:cy],
    )

    I18n.with_locale(:cy) do
      published_worldwide_organisation.social_media_accounts.first.update!(
        title: "Title in Welsh",
        url: "https://www.gov.cymru",
      )
    end

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))

    assert_equal published_worldwide_organisation.social_media_accounts.first.title, draft_worldwide_organisation.social_media_accounts.first.title
    assert_equal published_worldwide_organisation.social_media_accounts.first.url, draft_worldwide_organisation.social_media_accounts.first.url

    I18n.with_locale(:cy) do
      assert_equal "Title in Welsh", draft_worldwide_organisation.social_media_accounts.first.title
      assert_equal "https://www.gov.cymru", draft_worldwide_organisation.social_media_accounts.first.url
    end
  end

  test "should clone office and contact associations when new draft of published edition is created" do
    contact = create(:contact, translated_into: [:es])
    published_worldwide_organisation = create(:editionable_worldwide_organisation, :published)
    create(:worldwide_office, worldwide_organisation: nil, edition: published_worldwide_organisation, contact:)

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))
    published_worldwide_organisation.reload

    assert_equal published_worldwide_organisation.offices.first.attributes.except("id", "edition_id"),
                 draft_worldwide_organisation.offices.first.attributes.except("id", "edition_id")
    assert_equal published_worldwide_organisation.offices.first.contact.attributes.except("id", "contactable_id"),
                 draft_worldwide_organisation.offices.first.contact.attributes.except("id", "contactable_id")
    assert_equal published_worldwide_organisation.main_office.attributes.except("id", "edition_id"),
                 draft_worldwide_organisation.main_office.attributes.except("id", "edition_id")
    assert_equal published_worldwide_organisation.offices.first.contact.translations.find_by(locale: :es).attributes.except("id", "contact_id"),
                 draft_worldwide_organisation.offices.first.contact.translations.find_by(locale: :es).attributes.except("id", "contact_id")
    assert_equal published_worldwide_organisation.offices.first.contact.translations.find_by(locale: :en).attributes.except("id", "contact_id"),
                 draft_worldwide_organisation.offices.first.contact.translations.find_by(locale: :en).attributes.except("id", "contact_id")
  end

  test "should retain home page lists for offices when new draft of published edition is created" do
    published_worldwide_organisation = create(:editionable_worldwide_organisation, :published, :with_main_office, :with_home_page_offices)

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))
    published_worldwide_organisation.reload

    assert_equal published_worldwide_organisation.home_page_offices.first.attributes.except("id", "edition_id"),
                 draft_worldwide_organisation.home_page_offices.first.attributes.except("id", "edition_id")
  end

  test "should clone default news image when new draft of published edition is created" do
    published_worldwide_organisation = create(
      :editionable_worldwide_organisation,
      :published,
      :with_default_news_image,
    )

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))

    assert_equal published_worldwide_organisation.default_news_image.attributes.except("id", "featured_imageable_id"), draft_worldwide_organisation.default_news_image.attributes.except("id", "featured_imageable_id")
    published_worldwide_organisation.default_news_image.assets.each_with_index do |asset, index|
      assert_equal asset.attributes.except("id", "assetable_id"), draft_worldwide_organisation.default_news_image.assets[index].attributes.except("id", "assetable_id")
    end
  end

  test "should clone pages when a new draft of published edition is created" do
    published_worldwide_organisation = create(:editionable_worldwide_organisation, :published, translated_into: [:fr])
    create(:worldwide_organisation_page, edition: published_worldwide_organisation, translated_into: [:fr])

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))

    assert_equal published_worldwide_organisation.reload.pages.first.attributes.except("id", "edition_id"), draft_worldwide_organisation.pages.first.attributes.except("id", "edition_id")
    assert_equal published_worldwide_organisation.pages.first.translations.find_by(locale: :fr).attributes.except("id", "worldwide_organisation_page_id"),
                 draft_worldwide_organisation.pages.first.translations.find_by(locale: :fr).attributes.except("id", "worldwide_organisation_page_id")
    assert_equal published_worldwide_organisation.pages.first.translations.find_by(locale: :en).attributes.except("id", "worldwide_organisation_page_id"),
                 draft_worldwide_organisation.pages.first.translations.find_by(locale: :en).attributes.except("id", "worldwide_organisation_page_id")
  end

  test "should clone page attachments when a new draft of published edition is created" do
    page = create(:worldwide_organisation_page)
    attachment = build(:file_attachment)
    page.attachments << attachment
    published_worldwide_organisation = create(:editionable_worldwide_organisation, :published, pages: [page])

    draft_worldwide_organisation = published_worldwide_organisation.create_draft(create(:writer))

    cloned_attachment = draft_worldwide_organisation.pages.first.attachments.first
    assert_equal cloned_attachment.attributes.except("id", "attachable_id", "safely_resluggable"), attachment.attributes.except("id", "attachable_id", "safely_resluggable")
  end

  test "when destroyed, will remove its home page list for storing offices" do
    world_organisation = create(:editionable_worldwide_organisation)
    h = world_organisation.__send__(:home_page_offices_list)
    world_organisation.destroy!
    assert_not HomePageList.exists?(h.id)
  end

  test "has an overridable default main office" do
    worldwide_organisation = create(:editionable_worldwide_organisation)

    assert_nil worldwide_organisation.main_office

    office1 = create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation)
    assert_equal office1, worldwide_organisation.main_office

    office2 = create(:worldwide_office, worldwide_organisation: nil, edition: worldwide_organisation)
    worldwide_organisation.offices << office2
    assert_equal office1, worldwide_organisation.main_office

    worldwide_organisation.main_office = office2
    assert_equal office2, worldwide_organisation.main_office
  end

  test "distinguishes between the main office and other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]
    worldwide_organisation = build(:editionable_worldwide_organisation, offices:, main_office: offices.last)

    assert worldwide_organisation.is_main_office?(offices.last)
    assert_not worldwide_organisation.is_main_office?(offices.first)
  end

  test "can list other offices" do
    offices = [build(:worldwide_office), build(:worldwide_office)]

    assert_equal [], build(:editionable_worldwide_organisation, offices: []).other_offices
    assert_equal [], build(:editionable_worldwide_organisation, offices: offices.take(1)).other_offices
    assert_equal [offices.last], build(:editionable_worldwide_organisation, offices:, main_office: offices.first).other_offices
  end

  test "knows if a given office is on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    office = build(:worldwide_office, worldwide_organisation: nil)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:shown_on_home_page?).with(office).returns :the_answer

    assert_equal :the_answer, world_organisation.office_shown_on_home_page?(office)
  end

  test "knows that the main office is on the home page, even if it's not explicitly in the list" do
    world_organisation = create(:editionable_worldwide_organisation)
    office1 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    office2 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    world_organisation.add_office_to_home_page!(office1)
    world_organisation.main_office = office2

    assert world_organisation.office_shown_on_home_page?(office2)
  end

  test "has a list of offices that are on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:items).returns [:the_list_of_offices]

    assert_equal [:the_list_of_offices], world_organisation.home_page_offices
  end

  test "the list of offices that are on its home page excludes the main office" do
    world_organisation = create(:editionable_worldwide_organisation)
    office1 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    office2 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    office3 = create(:worldwide_office, worldwide_organisation: nil, edition: world_organisation)
    world_organisation.add_office_to_home_page!(office1)
    world_organisation.add_office_to_home_page!(office2)
    world_organisation.add_office_to_home_page!(office3)
    world_organisation.main_office = office2

    assert_equal [office1, office3], world_organisation.home_page_offices
  end

  test "can add a office to the list of those that are on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    office = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:add_item).with(office).returns :a_result

    assert_equal :a_result, world_organisation.add_office_to_home_page!(office)
  end

  test "can remove a office from the list of those that are on its home page" do
    world_organisation = build(:editionable_worldwide_organisation)
    office = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:remove_item).with(office).returns :a_result

    assert_equal :a_result, world_organisation.remove_office_from_home_page!(office)
  end

  test "can reorder the contacts on the list" do
    world_organisation = build(:editionable_worldwide_organisation)
    office1 = build(:worldwide_office)
    office2 = build(:worldwide_office)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:reorder_items!).with([office1, office2]).returns :a_result

    assert_equal :a_result, world_organisation.reorder_offices_on_home_page!([office1, office2])
  end

  test "maintains a home page list for storing offices" do
    world_organisation = build(:editionable_worldwide_organisation)
    HomePageList.expects(:get).with(has_entries(owned_by: world_organisation, called: "offices")).returns :a_home_page_list_of_offices
    assert_equal :a_home_page_list_of_offices, world_organisation.__send__(:home_page_offices_list)
  end

  test "#corporate_information_page_types does not return `About Us` pages" do
    organisation = build(:editionable_worldwide_organisation)

    assert_not_includes organisation.corporate_information_page_types.map(&:slug), "about"
    assert_not_includes organisation.corporate_information_page_types.map(&:id), 20
  end

  test "should support attachments" do
    organisation = build(:editionable_worldwide_organisation)
    organisation.attachments << build(:file_attachment)
  end
end
