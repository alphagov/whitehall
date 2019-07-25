require 'test_helper'

class Api::WorldwideOrganisationPresenterTest < PresenterTestCase
  setup do
    @access_times = stub_record(:access_and_opening_times, body: 'never')
    @main_sponsor = stub_translatable_record(:organisation)
    @office = stub_record(:worldwide_office, contact: stub_translatable_record(:contact, contact_numbers: []),
                                             services: [],
                                             worldwide_organisation: nil,
                                             access_and_opening_times: @access_times)
    @world_org = stub_translatable_record(:worldwide_organisation, sponsoring_organisations: [@main_sponsor],
                                                      offices: [@office],
                                                      access_and_opening_times: @access_times)
    @world_org.stubs(:summary).returns('summary')
    @presenter = Api::WorldwideOrganisationPresenter.new(@world_org, @view_context)
    stubs_helper_method(:params).returns(format: :json)
    stubs_helper_method(:govspeak_to_html).returns('govspoken')
  end

  test ".paginate returns a decorated page of results" do
    stubs_helper_method(:params).returns(page: 1)
    page = [@world_org]
    Api::Paginator.stubs(:paginate).with([@world_org], page: 1).returns(page)

    paginated = Api::WorldwideOrganisationPresenter.paginate([@world_org], @view_context)

    assert_equal Api::PagePresenter, paginated.class
    assert_equal 1, paginated.page.size
    assert_equal Api::WorldwideOrganisationPresenter, paginated.page.first.class
    assert_equal @world_org, paginated.page.first.model
  end

  test 'links has a self link, pointing to the request-relative api worldwide organisations url' do
    self_link = @presenter.links.detect { |(_url, attrs)| attrs['rel'] == 'self' }
    assert self_link
    url, _attrs = *self_link
    assert_equal api_worldwide_organisation_url(@world_org), url
  end

  test "json includes request-relative api worldwide organisations url as id" do
    assert_equal api_worldwide_organisation_url(@world_org), @presenter.as_json[:id]
  end

  test "json includes world org name as title" do
    @world_org.stubs(:name).returns('world-org-name')
    assert_equal 'world-org-name', @presenter.as_json[:title]
  end

  test "json includes 'Worldwide Organisation' as format" do
    assert_equal 'Worldwide Organisation', @presenter.as_json[:format]
  end

  test "json includes world org updated_at as updated_at" do
    now = Time.current
    @world_org.stubs(:updated_at).returns(now)
    assert_equal now, @presenter.as_json[:updated_at]
  end

  test "json includes slug in details hash" do
    @world_org.stubs(:slug).returns('world-org-slug')
    assert_equal 'world-org-slug', @presenter.as_json[:details][:slug]
  end

  test "json includes analytics_identifier in details hash" do
    @world_org.stubs(:analytics_identifier).returns('WO123')
    assert_equal 'WO123', @presenter.as_json[:analytics_identifier]
  end

  test "json includes public world organisations url as web_url" do
    assert_equal Whitehall.url_maker.worldwide_organisation_url(@world_org), @presenter.as_json[:web_url]
  end

  test 'json includes office sponsoring org name in sponsors array as title' do
    @main_sponsor.stubs(:name).returns('sponsor-title')
    assert_equal 'sponsor-title', @presenter.as_json[:sponsors].first[:title]
  end

  test 'json includes office sponsoring org acronym in sponsors array as acronym' do
    @main_sponsor.stubs(:acronym).returns('SA')
    assert_equal 'SA', @presenter.as_json[:sponsors].first[:details][:acronym]
  end

  test "json includes public organisations url for sponsor in sponsors array as web_url" do
    assert_equal Whitehall.url_maker.organisation_url(@main_sponsor), @presenter.as_json[:sponsors].first[:web_url]
  end

  test 'json includes office contact title in offices as title' do
    @office.contact.stubs(:title).returns('office-title')
    assert_equal 'office-title', @presenter.as_json[:offices][:main][:title]
  end

  test 'json includes public office url in offices as web_url' do
    assert_equal Whitehall.url_maker.worldwide_organisation_worldwide_office_url(@world_org, @office), @presenter.as_json[:offices][:main][:web_url]
  end

  test 'json includes office contact comments in offices as description' do
    @office.contact.stubs(:comments).returns('office-comments')
    assert_equal 'office-comments', @presenter.as_json[:offices][:main][:details][:description]
  end

  test 'json includes office contact email in offices as email' do
    @office.contact.stubs(:email).returns('office-email')
    assert_equal 'office-email', @presenter.as_json[:offices][:main][:details][:email]
  end

  test 'json includes office contact contact form url in offices as email' do
    @office.contact.stubs(:contact_form_url).returns('office-contact-form-url')
    assert_equal 'office-contact-form-url', @presenter.as_json[:offices][:main][:details][:contact_form_url]
  end

  test "json includes govspoken access_and_opening_times_body in details hash of an office" do
    @office.stubs(:access_and_opening_times_body).returns('world-office-access-and-opening-times')
    stubs_helper_method(:govspeak_to_html).with('world-office-access-and-opening-times').returns('govspoken-world-office-access-and-opening-times')
    assert_equal 'govspoken-world-office-access-and-opening-times', @presenter.as_json[:offices][:main][:details][:access_and_opening_times]
  end

  test "json includes empty string for access_and_opening_times_body if they are missing for an office" do
    @office.stubs(:access_and_opening_times_body).returns(nil)
    assert_equal '', @presenter.as_json[:offices][:main][:details][:access_and_opening_times]
  end

  test 'json does not include main key in offices if there is no main office' do
    @world_org.stubs(:main_office).returns(nil)
    assert_not @presenter.as_json[:offices].has_key?(:main)
  end

  test 'json includes main and other offices in offices with separate keys' do
    office_1 = stub_record(:worldwide_office, contact: stub_translatable_record(:contact, title: 'best-office', contact_numbers: []),
                                             services: [],
                                             worldwide_organisation: nil,
                                             access_and_opening_times: @access_times)
    office_2 = stub_record(:worldwide_office, contact: stub_translatable_record(:contact, title: 'worst-office', contact_numbers: []),
                                             services: [],
                                             worldwide_organisation: nil,
                                             access_and_opening_times: @access_times)

    @world_org.stubs(:main_office).returns(office_1)
    @world_org.stubs(:other_offices).returns([office_2])
    main_office_as_json = @presenter.as_json[:offices][:main]
    other_offices_as_json = @presenter.as_json[:offices][:other]

    assert_equal 'best-office', main_office_as_json[:title]
    assert_equal 1, other_offices_as_json.size
    assert_equal 'worst-office', other_offices_as_json.first[:title]
  end

  test 'json includes office contact phone numbers in offices array as contact_numbers' do
    contact_numbers = [stub_translatable_record(:contact_number, contact: @office.contact, label: 'contact-number-one', number: '1234'),
                       stub_translatable_record(:contact_number, contact: @office.contact, label: 'contact-number-two', number: '5678')]
    @office.contact.stubs(:contact_numbers).returns(contact_numbers)

    office_as_json = @presenter.as_json[:offices][:main]
    assert_equal 2, office_as_json[:contact_numbers].size
    expected_contact_num_json = { label: 'contact-number-one', number: '1234' }
    assert_equal expected_contact_num_json, office_as_json[:contact_numbers][0]
    expected_contact_num_json = { label: 'contact-number-two', number: '5678' }
    assert_equal expected_contact_num_json, office_as_json[:contact_numbers][1]
  end

  test 'json includes office services in offices array as services' do
    services = [stub_record(:worldwide_service, name: 'service-one', service_type: WorldwideServiceType::AssistanceServices),
                stub_record(:worldwide_service, name: 'service-two', service_type: WorldwideServiceType::OtherServices)]
    @office.stubs(:services).returns services
    office_as_json = @presenter.as_json[:offices][:main]
    assert_equal 2, office_as_json[:services].size
    expected_service_json = { title: 'service-one', type: WorldwideServiceType::AssistanceServices.name }
    assert_equal expected_service_json, office_as_json[:services][0]
    expected_service_json = { title: 'service-two', type: WorldwideServiceType::OtherServices.name }
    assert_equal expected_service_json, office_as_json[:services][1]
  end

  test 'json includes office contact address in offices array' do
    json_formatted_address = { 'address' => 'as-json' }
    formatter = mock
    formatter.stubs(:render).returns(json_formatted_address)
    AddressFormatter::Json.stubs(:from_contact).returns(formatter)

    assert_equal 'as-json', @presenter.as_json[:offices][:main]['address']
  end

  test 'json includes office type in offices array as type in details hash' do
    @office.stubs(:worldwide_office_type).returns WorldwideOfficeType::Embassy
    assert_equal WorldwideOfficeType::Embassy.name, @presenter.as_json[:offices][:main][:details][:type]
  end
end
