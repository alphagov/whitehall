require "test_helper"

class Admin::OrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "index should list all the organisations in alphabetical order" do
    organisations = [create(:organisation, name: "org 1"), create(:organisation, name: "org 2")]
    get :index
    assert_equal organisations, assigns(:organisations)
  end

  test "should allow entry of new organisation data" do
    get :new
    assert_template "organisations/new"
    assert_select "input[type=text][name='organisation[alternative_format_contact_email]']"
    assert_select "textarea[name='organisation[description]']"
    assert_select "textarea[name='organisation[about_us]'].previewable"
    assert_select "#govspeak_help"
    assert_select parent_organisations_list_selector
    assert_select organisation_type_list_selector
    assert_select organisation_topics_list_selector
    assert_select organisation_govuk_status_selector
    assert_select "input[type=text][name='organisation[contacts_attributes][0][description]']"
    assert_select "textarea[name='organisation[contacts_attributes][0][address]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][postcode]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][email]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][contact_form_url]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][contact_numbers_attributes][0][label]']"
    assert_select "input[type=text][name='organisation[contacts_attributes][0][contact_numbers_attributes][0][number]']"
    assert_select "select[name='organisation[organisation_logo_type_id]']"
  end

  test "should display social media account fields for new organisation" do
    get :new

    assert_select "select[name='organisation[social_media_accounts_attributes][0][social_media_service_id]']" do
      refute_select "option[selected='selected']"
      assert_select "option", text: ""
    end
    assert_select "input[type=text][name='organisation[social_media_accounts_attributes][0][url]']"
  end

  test "should display fields for new organisation mainstream links" do
    get :new

    assert_select "input[type=text][name='organisation[organisation_mainstream_links_attributes][0][url]']"
    assert_select "input[type=text][name='organisation[organisation_mainstream_links_attributes][0][title]']"
  end

  test "should allow creation of an organisation without any contact details" do
    organisation_type = create(:organisation_type)

    post :create, organisation: {
      name: "Anything",
      logo_formatted_name: "Anything",
      organisation_type_id: organisation_type.id,
      contacts_attributes: [{description: "", contact_numbers_attributes: [{label: "", number: ""}]}]
    }

    organisation = Organisation.last
    assert_kind_of Organisation, organisation
    assert_equal "Anything", organisation.name
  end

  test "creating should create a new Organisation" do
    attributes = attributes_for(:organisation,
      description: "organisation-description",
      about_us: "organisation-about-us",
      alternative_format_contact_email: "alternative@example.com"
    )

    organisation_type = create(:organisation_type)
    topic = create(:topic)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      classification_ids: [topic.id],
      contacts_attributes: [{description: "Enquiries", contact_numbers_attributes: [{label: "Fax", number: "020712435678"}]}],
      organisation_logo_type_id: OrganisationLogoType::BusinessInnovationSkills.id
    )

    assert organisation = Organisation.last
    assert_equal attributes[:name], organisation.name
    assert_equal attributes[:description], organisation.description
    assert_equal attributes[:about_us], organisation.about_us
    assert_equal attributes[:alternative_format_contact_email], organisation.alternative_format_contact_email
    assert_equal 1, organisation.contacts.count
    assert_equal "Enquiries", organisation.contacts[0].description
    assert_equal 1, organisation.contacts[0].contact_numbers.count
    assert_equal "Fax", organisation.contacts[0].contact_numbers[0].label
    assert_equal "020712435678", organisation.contacts[0].contact_numbers[0].number
    assert_equal topic, organisation.topics.first
    assert_equal OrganisationLogoType::BusinessInnovationSkills, organisation.organisation_logo_type
  end

  test "creating correctly set ordering of topics" do
    attributes = attributes_for(:organisation)

    organisation_type = create(:organisation_type)
    topic_ids = [create(:topic), create(:topic)].map(&:id)

    post :create, organisation: attributes.merge(
      organisation_classifications_attributes: [
        {classification_id: topic_ids[0], ordering: 1 },
        {classification_id: topic_ids[1], ordering: 2 }
      ],
      organisation_type_id: organisation_type.id
    )

    assert organisation = Organisation.last
    assert organisation.organisation_classifications.map(&:ordering).all?(&:present?), "no ordering"
    assert_equal organisation.organisation_classifications.map(&:ordering).sort, organisation.organisation_classifications.map(&:ordering).uniq.sort
    assert_equal topic_ids, organisation.organisation_classifications.sort_by(&:ordering).map(&:classification_id)
  end

  test "creating should be able to create a new social media account for the organisation" do
    attributes = attributes_for(:organisation)
    organisation_type = create(:organisation_type)
    social_media_service = create(:social_media_service)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      social_media_accounts_attributes: {"0" =>{
        social_media_service_id: social_media_service.id,
        url: "https://twitter.com/#!/bisgovuk"
      }}
    )

    assert organisation = Organisation.last
    assert social_media_account = organisation.social_media_accounts.last
    assert_equal social_media_service, social_media_account.social_media_service
    assert_equal "https://twitter.com/#!/bisgovuk", social_media_account.url
  end

  test "creating should be able to create a new mainstream link for the organisation" do
    attributes = attributes_for(:organisation)
    organisation_type = create(:organisation_type)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      organisation_mainstream_links_attributes: {"0" =>{
        url: "http://www.gov.uk/mainstream/something",
        title: "Something on mainstream"
      }}
    )

    assert organisation = Organisation.last
    assert organisation_mainstream_link = organisation.organisation_mainstream_links.last
    assert_equal "http://www.gov.uk/mainstream/something", organisation_mainstream_link.url
    assert_equal "Something on mainstream", organisation_mainstream_link.title
  end

  test "updating should destroy existing mainstream links if all its field are blank" do
    attributes = attributes_for(:organisation)
    organisation = create(:organisation, attributes)
    link = create(:organisation_mainstream_link, organisation: organisation)

    put :update, id: organisation, organisation: attributes.merge(
      organisation_mainstream_links_attributes: {"0" =>{
          id: link.id,
          url: "",
          title: ""
      }}
    )

    assert_equal 0, organisation.organisation_mainstream_links.length
  end

  test "creating should redirect back to the index" do
    organisation_type = create(:organisation_type)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id
    )

    assert_redirected_to admin_organisations_path
  end

  test "creating with invalid data should reshow the edit form" do
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(name: '')

    assert_template "organisations/new"
  end

  test "creating with invalid data should display social media account fields" do
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(name: '')

    assert_select "select[name='organisation[social_media_accounts_attributes][0][social_media_service_id]']" do
      refute_select "option[selected='selected']"
      assert_select "option", text: ""
    end
    assert_select "input[type=text][name='organisation[social_media_accounts_attributes][0][url]']"
  end

  test "creating with multiple parent organisations" do
    organisation_type = create(:organisation_type)
    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      name: "new-organisation",
      organisation_type_id: organisation_type.id,
      parent_organisation_ids: [parent_org_1.id, parent_org_2.id]
    )
    created_organisation = Organisation.find_by_name("new-organisation")
    assert_equal [parent_org_1, parent_org_2], created_organisation.parent_organisations
  end

  test "creating with an organisation type" do
    organisation_type = create(:organisation_type)
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id
    )
    created_organisation = Organisation.last
    assert_equal organisation_type, created_organisation.organisation_type
  end

  test "creating with a govuk status" do
    attributes = attributes_for(:organisation)
    post :create, organisation: attributes.merge(
      govuk_status: 'exempt',
      organisation_type_id: create(:organisation_type).id
    )
    assert_equal 'exempt', Organisation.last.govuk_status
  end

  test "creating with blank numbers ignores blank numbers" do
    attributes = attributes_for(:organisation,
      description: "organisation-description",
      about_us: "organisation-about-us"
    )

    organisation_type = create(:organisation_type)
    topic = create(:topic)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      classification_ids: [topic.id],
      contacts_attributes: {"0" => {
        description: "Enquiries",
        contact_numbers_attributes: {
          "0" => { label: " ", number: " " },
          "1" => { label: " ", number: " " }
        }
      }}
    )

    created_organisation = Organisation.last
    assert_not_nil created_organisation
    assert_equal 0, created_organisation.contacts.first.contact_numbers.size
  end

  test "creating ignores blank social media accounts" do
    attributes = attributes_for(:organisation)
    organisation_type = create(:organisation_type)

    post :create, organisation: attributes.merge(
      organisation_type_id: organisation_type.id,
      social_media_accounts_attributes: {"0" => {social_media_service_id: "", url: "" }}
    )

    assert created_organisation = Organisation.last
    assert_equal 0, created_organisation.social_media_accounts.size
  end

  test "showing should load the requested organisation" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_equal organisation, assigns(:organisation)
  end

  test "showing displays the govuk status" do
    organisation = create(:organisation, govuk_status: 'exempt')
    get :show, id: organisation
    assert_select 'td', text: 'Exempt'
  end

  test "showing should allow featured published news articles to be unfeatured" do
    published_news_article = create(:published_news_article)
    organisation = create(:organisation)
    edition_organisation = create(:featured_edition_organisation, organisation: organisation, edition: published_news_article)

    get :show, id: organisation

    assert_select "form[action=#{admin_edition_organisation_path(edition_organisation)}]" do
      assert_select "input[name='edition_organisation[featured]'][value='false']"
    end
  end

  test "showing should display all editions most recently published first" do
    earlier_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    later_policy = create(:published_policy, first_published_at: 1.days.ago)
    organisation = create(:organisation, editions: [earlier_news_article, later_policy])

    get :show, id: organisation

    assert_equal [later_policy, earlier_news_article], assigns(:editions)
  end

  test "showing should display published editions related to the organisation" do
    published_news_article = create(:published_news_article)
    published_policy = create(:published_policy)
    draft_news_article = create(:draft_news_article)
    another_policy = create(:published_policy)
    organisation = create(:organisation, editions: [published_news_article, published_policy, draft_news_article])

    get :show, id: organisation

    assert_select_object(published_news_article)
    assert_select_object(published_policy)
    refute_select_object(draft_news_article)
    refute_select_object(another_policy)
  end

  test "editing should allow non-featured published news articles to be featured" do
    published_news_article = create(:published_news_article)
    organisation = create(:organisation)
    edition_organisation = create(:edition_organisation, organisation: organisation, edition: published_news_article)

    get :show, id: organisation

    assert_select "a[href=?]", edit_admin_edition_organisation_path(edition_organisation), text: "Feature"
  end

  test "editing should load the requested organisation" do
    organisation = create(:organisation)
    get :edit, id: organisation
    assert_equal organisation, assigns(:organisation)
  end

  test "editing should not show the current organisation in the list of parent organisations" do
    organisation = create(:organisation)
    get :edit, id: organisation
    refute_select "#{parent_organisations_list_selector} option[value='#{organisation.id}']"
  end

  test "edit should show only departments in the list of parent organisations" do
    org1 = create(:organisation)
    org2 = create(:organisation)
    dept = create(:ministerial_department)
    get :edit, id: org1
    refute_select "#{parent_organisations_list_selector} option[value='#{org2.id}']"
    assert_select "#{parent_organisations_list_selector} option[value='#{dept.id}']"
  end

  test "editing should display a cancel link back to the list of organisations" do
    organisation = create(:organisation)
    get :edit, id: organisation
    assert_select ".or_cancel a[href='#{admin_organisation_path(organisation)}']"
  end

  test "editing should display existing social media accounts" do
    twitter = create(:social_media_service, name: "Twitter")
    account = create(:social_media_account, social_media_service: twitter, url: "http://twitter.com/foo")
    organisation = create(:organisation, social_media_accounts: [account])

    get :edit, id: organisation

    assert_select "select[name='organisation[social_media_accounts_attributes][0][social_media_service_id]']" do
      assert_select "option[value='#{twitter.id}'][selected='selected']", text: "Twitter"
    end
    assert_select "input[type=text][name='organisation[social_media_accounts_attributes][0][url]'][value='http://twitter.com/foo']"
  end

  test "editing should display new blank social media account" do
    organisation = create(:organisation, social_media_accounts: [])

    get :edit, id: organisation

    assert_select "select[name='organisation[social_media_accounts_attributes][0][social_media_service_id]']" do
      refute_select "option[selected='selected']"
      assert_select "option", text: ""
    end
    assert_select "input[type=text][name='organisation[social_media_accounts_attributes][0][url]']"
  end

  test "editing shows roles for ordering in separate lists" do
    ministerial_role = create(:ministerial_role)
    board_member_role = create(:board_member_role)
    chief_scientific_advisor_role = create(:chief_scientific_advisor_role)
    traffic_commissioner_role = create(:traffic_commissioner_role)
    military_role = create(:military_role)

    organisation = create(:organisation)
    organisation_ministerial_role = create(:organisation_role, organisation: organisation, role: ministerial_role)
    organisation_board_member_role = create(:organisation_role, organisation: organisation, role: board_member_role)
    organisation_scientific_role = create(:organisation_role, organisation: organisation, role: chief_scientific_advisor_role)
    organisation_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: traffic_commissioner_role)
    organisation_military_role = create(:organisation_role, organisation: organisation, role: military_role)

    get :edit, id: organisation

    assert_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    refute_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"
    refute_select "#minister_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"

    assert_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    assert_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"
    refute_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#board_member_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"

    assert_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"
    refute_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    refute_select "#traffic_commissioner_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"

    assert_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_military_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_ministerial_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_board_member_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_traffic_commissioner_role.id}]"
    refute_select "#military_ordering input[name^='organisation[organisation_roles_attributes]'][value=#{organisation_scientific_role.id}]"
  end

  test "editing shows ministerial role and current person's name" do
    person = create(:person, forename: "John", surname: "Doe")
    ministerial_role = create(:ministerial_role, name: "Prime Minister")
    create(:role_appointment, person: person, role: ministerial_role, started_at: 1.day.ago)
    organisation = create(:organisation, roles: [ministerial_role])

    get :edit, id: organisation

    assert_select "#minister_ordering label", text: /Prime Minister/i
    assert_select "#minister_ordering label", text: /John Doe/i
  end

  test "editing shows ministerial roles in their currently specified order" do
    junior_ministerial_role = create(:ministerial_role)
    senior_ministerial_role = create(:ministerial_role)
    organisation = create(:organisation)
    organisation_junior_ministerial_role = create(:organisation_role, organisation: organisation, role: junior_ministerial_role, ordering: 2)
    organisation_senior_ministerial_role = create(:organisation_role, organisation: organisation, role: senior_ministerial_role, ordering: 1)

    get :edit, id: organisation

    assert_equal [organisation_senior_ministerial_role, organisation_junior_ministerial_role], assigns(:ministerial_organisation_roles)
  end

  test "editing shows board member roles in their currently specified order" do
    junior_board_member_role = create(:board_member_role)
    senior_board_member_role = create(:board_member_role)
    chief_scientific_advisor_role = create(:chief_scientific_advisor_role)

    organisation = create(:organisation)
    organisation_chief_scientific_advisor_role = create(:organisation_role, organisation: organisation, role: chief_scientific_advisor_role, ordering: 2)
    organisation_junior_board_member_role = create(:organisation_role, organisation: organisation, role: junior_board_member_role, ordering: 3)
    organisation_senior_board_member_role = create(:organisation_role, organisation: organisation, role: senior_board_member_role, ordering: 1)

    get :edit, id: organisation

    assert_equal [
      organisation_senior_board_member_role,
      organisation_chief_scientific_advisor_role,
      organisation_junior_board_member_role
    ], assigns(:management_organisation_roles)
  end

  test "editing shows traffic commissioner roles in their currently specified order" do
    junior_traffic_commissioner_role = create(:traffic_commissioner_role)
    senior_traffic_commissioner_role = create(:traffic_commissioner_role)
    organisation = create(:organisation)
    organisation_junior_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: junior_traffic_commissioner_role, ordering: 2)
    organisation_senior_traffic_commissioner_role = create(:organisation_role, organisation: organisation, role: senior_traffic_commissioner_role, ordering: 1)

    get :edit, id: organisation

    assert_equal [organisation_senior_traffic_commissioner_role, organisation_junior_traffic_commissioner_role], assigns(:traffic_commissioner_organisation_roles)
  end

  test "editing shows special representative roles in their currently specified order" do
    junior_representative_role = create(:special_representative_role)
    senior_representative_role = create(:special_representative_role)
    organisation = create(:organisation)
    organisation_junior_representative_role = create(:organisation_role, organisation: organisation, role: junior_representative_role, ordering: 2)
    organisation_senior_representative_role = create(:organisation_role, organisation: organisation, role: senior_representative_role, ordering: 1)

    get :edit, id: organisation

    assert_equal [organisation_senior_representative_role, organisation_junior_representative_role], assigns(:special_representative_organisation_roles)
  end

  test "editing does not display an empty ministerial roles section" do
    organisation = create(:organisation)
    get :edit, id: organisation
    refute_select "#minister_ordering"
  end

  test "editing contains the relevant dom classes to facilitate the javascript ordering functionality" do
    organisation = create(:organisation, roles: [create(:ministerial_role)])
    get :edit, id: organisation
    assert_select "fieldset#minister_ordering.sortable input.ordering[name^='organisation[organisation_roles_attributes]']"
  end

  test "allows updating of organisation role ordering" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)
    organisation_role = create(:organisation_role, organisation: organisation, role: ministerial_role, ordering: 1)

    put :update, id: organisation.id, organisation: {organisation_roles_attributes: {
      "0" => {id: organisation_role.id, ordering: "2"}
    }}

    assert_equal 2, organisation_role.reload.ordering
  end

  test "failing to update an organisation should render the list of ministerial roles" do
    ministerial_role = create(:ministerial_role)
    organisation = create(:organisation)
    organisation_ministerial_role = create(:organisation_role, organisation: organisation, role: ministerial_role)

    put :update, id: organisation, organisation: {name: ""}

    assert_equal [organisation_ministerial_role], assigns(:ministerial_organisation_roles)
  end

  test "updating should modify the organisation" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Noise",
      description: "organisation-description",
      about_us: "organisation-about-us"
    }

    put :update, id: organisation, organisation: organisation_attributes

    organisation.reload
    assert_equal "Ministry of Noise", organisation.name
    assert_equal "organisation-description", organisation.description
    assert_equal "organisation-about-us", organisation.about_us
  end

  test "updating without a name should reshow the edit form" do
    organisation = create(:organisation, name: "Ministry of Sound")

    put :update, id: organisation, organisation: {name: ""}

    assert_template "organisations/edit"
  end

  test "updating with an empty contact should not create that contact" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Sound",
      contacts_attributes: [{description: "", number: ""}]
    }

    put :update, id: organisation, organisation: organisation_attributes

    assert_equal 0, organisation.contacts.count
  end

  test "update should remove all related topics if none specified" do
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation,
      organisation_attributes.merge(topics: [create(:topic)])
    )

    put :update, id: organisation, organisation: organisation_attributes.merge(classification_ids: [""])

    organisation.reload
    assert_equal [], organisation.topics
  end

  test "update should remove all parent organisations if none specified" do
    organisation_attributes = {name: "Ministry of Sound"}
    organisation = create(:organisation,
      organisation_attributes.merge(parent_organisation_ids: [create(:organisation).id])
    )

    put :update, id: organisation, organisation: organisation_attributes.merge(parent_organisation_ids: [""])

    organisation.reload
    assert_equal [], organisation.parent_organisations
  end

  test "updating with blank numbers destroys those blank numbers" do
    organisation = create(:organisation)
    contact = create(:contact, organisation: organisation)
    contact_number = create(:contact_number, contact: contact)

    put :update, id: organisation, organisation: { contacts_attributes: { 0 => {
      id: contact,
      contact_numbers_attributes: {
        0 => { label: " ", number: " ", id: contact_number }
      }
    }}}

    contact.reload
    assert_equal 0, contact.contact_numbers.count
  end

  test "updating should create new social media account" do
    organisation = create(:organisation)
    social_media_service = create(:social_media_service)

    put :update, id: organisation, organisation: organisation.attributes.merge(
      social_media_accounts_attributes: {"0" => {
        social_media_service_id: social_media_service.id,
        url: "https://twitter.com/#!/bisgovuk"
      }}
    )

    assert social_media_account = organisation.social_media_accounts.last
    assert_equal social_media_service, social_media_account.social_media_service
    assert_equal "https://twitter.com/#!/bisgovuk", social_media_account.url
  end

  test "updating should destroy existing social media account if all its field are blank" do
    attributes = attributes_for(:organisation)
    organisation = create(:organisation, attributes)
    account = create(:social_media_account, socialable: organisation)

    put :update, id: organisation, organisation: attributes.merge(
      social_media_accounts_attributes: {"0" => {
        id: account.id,
        social_media_service_id: "",
        url: ""
      }}
    )

    assert_equal 0, organisation.social_media_accounts.count
  end

  test "updating with blank social media account fields should not create new account" do
    organisation = create(:organisation)

    put :update, id: organisation, organisation: organisation.attributes.merge(
      social_media_accounts_attributes: {"0" => {
        social_media_service_id: "",
        url: ""
      }}
    )

    assert organisation.social_media_accounts.empty?
  end

  test "updating with invalid data should still display blank social media account fields" do
    organisation = create(:organisation)

    put :update, id: organisation, organisation: organisation.attributes.merge(name: "")

    assert_select "select[name='organisation[social_media_accounts_attributes][0][social_media_service_id]']" do
      refute_select "option[selected='selected']"
      assert_select "option", text: ""
    end
    assert_select "input[type=text][name='organisation[social_media_accounts_attributes][0][url]']"
  end

  test "updating should allow ordering of featured editions" do
    organisation = create(:organisation)
    edition_association_1 = create(:featured_edition_organisation, organisation: organisation)
    edition_association_2 = create(:featured_edition_organisation, organisation: organisation)
    edition_association_3 = create(:featured_edition_organisation, organisation: organisation)

    put :update, id: organisation, organisation: {
      edition_organisations_attributes: {
        "0" => {"id" => edition_association_1.id, "ordering" => "3"},
        "1" => {"id" => edition_association_2.id, "ordering" => "2"},
        "2" => {"id" => edition_association_3.id, "ordering" => "1"}
      }
    }

    assert_equal 3, edition_association_1.reload.ordering
    assert_equal 2, edition_association_2.reload.ordering
    assert_equal 1, edition_association_3.reload.ordering
  end

  test "updating order of featured editions should not lose topics or parent organisations" do
    topic = create(:topic)
    parent_organisation = create(:organisation)
    organisation = create(:organisation, topics: [topic], parent_organisations: [parent_organisation])

    put :update, id: organisation, organisation: {edition_organisations_attributes: {}}

    assert_equal [topic], organisation.reload.topics
    assert_equal [parent_organisation], organisation.reload.parent_organisations
  end

  test "shows a list of corporate information pages" do
    corporate_information_page = create(:corporate_information_page)
    organisation = create(:organisation, corporate_information_pages: [corporate_information_page])

    get :show, id: organisation

    assert_select "#corporate_information_pages" do
      assert_select "tr td a[href='#{edit_admin_organisation_corporate_information_page_path(organisation, corporate_information_page)}']", corporate_information_page.title
    end
  end

  test "link to create a new corporate_information_page" do
    organisation = create(:organisation)

    get :show, id: organisation

    assert_select "#corporate_information_pages" do
      assert_select "a[href='#{new_admin_organisation_corporate_information_page_path(organisation)}']"
    end
  end

  test "no link to create corporate_information_page if all types already exist" do
    organisation = create(:organisation)
    CorporateInformationPageType.all.each do |type|
      organisation.corporate_information_pages << create(:corporate_information_page, type: type, body: "The body")
    end
    organisation.save

    get :show, id: organisation

    assert_select "#corporate_information_pages" do
      refute_select "a[href='#{new_admin_organisation_corporate_information_page_path(organisation)}']"
    end
  end

  test "show should display a list of groups" do
    organisation = create(:organisation, name: "organisation-name")
    group_one = create(:group, name: "group-one", organisation: organisation)
    group_two = create(:group, name: "group-two", organisation: organisation)

    get :show, id: organisation

    assert_select ".groups" do
      assert_select_object group_one do
        assert_select ".name", "group-one"
      end
      assert_select_object group_two do
        assert_select ".name", "group-two"
      end
    end
  end

  test "show should display groups in alphabetical order" do
    organisation = create(:organisation)
    group_A = create(:group, name: "A", organisation: organisation)
    group_C = create(:group, name: "C", organisation: organisation)
    group_B = create(:group, name: "B", organisation: organisation)

    get :show, id: organisation

    assert_equal [group_A, group_B, group_C], assigns(:organisation).groups
  end

  test "show should display a link to create a new group" do
    organisation = create(:organisation)
    get :show, id: organisation

    assert_select "#groups" do
      assert_select "a[href='#{new_admin_organisation_group_path(organisation)}']"
    end
  end

  test "show should display links to edit an existing group" do
    organisation = create(:organisation)
    group_one = create(:group, organisation: organisation)
    group_two = create(:group, organisation: organisation)

    get :show, id: organisation

    assert_select_object group_one do
      assert_select "a[href='#{edit_admin_organisation_group_path(organisation, group_one)}']"
    end
    assert_select_object group_two do
      assert_select "a[href='#{edit_admin_organisation_group_path(organisation, group_two)}']"
    end
  end

  test "show should display links to members of an existing group" do
    organisation = create(:organisation)
    person_one, person_two = create(:person), create(:person)
    group = create(:group, organisation: organisation, members: [person_one, person_two])

    get :show, id: organisation

    assert_select_object group do
      assert_select "a[href='#{edit_admin_person_path(person_one)}']"
      assert_select "a[href='#{edit_admin_person_path(person_two)}']"
    end
  end

  test "show provides delete buttons for destroyable groups" do
    organisation = create(:organisation)
    destroyable_group = create(:group, organisation: organisation, members: [])
    undestroyable_group = create(:group, organisation: organisation, members: [create(:person)])

    get :show, id: organisation

    assert_select_object destroyable_group do
      assert_select ".delete form[action='#{admin_organisation_group_path(organisation, destroyable_group)}']" do
        assert_select "input[name='_method'][value='delete']"
        assert_select "input[type='submit']"
      end
    end
    assert_select_object undestroyable_group do
      refute_select ".delete form"
    end
  end
end
