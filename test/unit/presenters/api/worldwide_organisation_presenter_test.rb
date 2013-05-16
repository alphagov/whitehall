require 'test_helper'

class Api::WorldwideOrganisationPresenterTest < PresenterTestCase
  setup do
    @main_sponsor = stub_record(:organisation, organisation_type: stub_record(:organisation_type))
    @office = stub_record(:worldwide_office, contact: stub_record(:contact, contact_numbers: []),
                                             services: [],
                                             worldwide_organisation: nil)
    @world_org = stub_record(:worldwide_organisation, sponsoring_organisations: [@main_sponsor],
                                                      offices: [@office])
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
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    self_link = @presenter.links.detect { |(url, attrs)| attrs['rel'] == 'self'}
    assert self_link
    url, attrs = *self_link
    assert_equal api_worldwide_organisation_url(@world_org, host: 'test.host'), url
  end

  test "json includes request-relative api worldwide organisations url as id" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal api_worldwide_organisation_url(@world_org, host: 'test.host'), @presenter.as_json[:id]
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

  test "json includes summary in details hash" do
    @world_org.stubs(:summary).returns('world-org-summary')
    assert_equal 'world-org-summary', @presenter.as_json[:details][:summary]
  end

  test "json includes govspoken description in details hash" do
    @world_org.stubs(:description).returns('world-org-description')
    stubs_helper_method(:govspeak_to_html).with('world-org-description').returns('govspoken-world-org-description')
    assert_equal 'govspoken-world-org-description', @presenter.as_json[:details][:description]
  end

  test "json includes govspoken services in details hash" do
    @world_org.stubs(:services).returns('world-org-services')
    stubs_helper_method(:govspeak_to_html).with('world-org-services').returns('govspoken-world-org-services')
    assert_equal 'govspoken-world-org-services', @presenter.as_json[:details][:services]
  end

  test "json includes empty string for services if they are missing" do
    @world_org.stubs(:services).returns(nil)
    assert_equal '', @presenter.as_json[:details][:services]
  end

  test "json includes public world organisations url as web_url" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal worldwide_organisation_url(@world_org, host: 'govuk.example.com'), @presenter.as_json[:web_url]
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
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal organisation_url(@main_sponsor, host: 'govuk.example.com'), @presenter.as_json[:sponsors].first[:web_url]
  end

  test 'json includes office contact title in offices as title' do
    @office.contact.stubs(:title).returns('office-title')
    assert_equal 'office-title', @presenter.as_json[:offices][:main][:title]
  end

  test 'json includes office contact comments in offices as decscription' do
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

  test 'json does not include main key in offices if there is no main office' do
    @world_org.stubs(:main_office).returns(nil)
    refute @presenter.as_json[:offices].has_key?(:main)
  end

  test 'json includes main and other offices in offices with separate keys' do
    office1 = stub_record(:worldwide_office, contact: stub_record(:contact, title: 'best-office', contact_numbers: []),
                                             services: [],
                                             worldwide_organisation: nil)
    office2 = stub_record(:worldwide_office, contact: stub_record(:contact, title: 'worst-office', contact_numbers: []),
                                             services: [],
                                             worldwide_organisation: nil)

    @world_org.stubs(:main_office).returns(office1)
    @world_org.stubs(:other_offices).returns([office2])
    main_office_as_json = @presenter.as_json[:offices][:main]
    other_offices_as_json = @presenter.as_json[:offices][:other]

    assert_equal 'best-office', main_office_as_json[:title]
    assert_equal 1, other_offices_as_json.size
    assert_equal 'worst-office', other_offices_as_json.first[:title]
  end

  test 'json includes office contact phone numbers in offices array as contact_numbers' do
    contact_numbers = [stub_record(:contact_number, label: 'contact-number-one', number: '1234'),
                       stub_record(:contact_number, label: 'contact-number-two', number: '5678')]
    @office.contact.stubs(:contact_numbers).returns(contact_numbers)

    office_as_json = @presenter.as_json[:offices][:main]
    assert_equal 2, office_as_json[:contact_numbers].size
    expected_contact_num_json = {label: 'contact-number-one', number: '1234'}
    assert_equal expected_contact_num_json, office_as_json[:contact_numbers][0]
    expected_contact_num_json = {label: 'contact-number-two', number: '5678'}
    assert_equal expected_contact_num_json, office_as_json[:contact_numbers][1]
  end

  test 'json includes office services in offices array as services' do
    services = [stub_record(:worldwide_service, name: 'service-one', service_type: WorldwideServiceType::AssistanceServices),
                stub_record(:worldwide_service, name: 'service-two', service_type: WorldwideServiceType::OtherServices)]
    @office.stubs(:services).returns services
    office_as_json = @presenter.as_json[:offices][:main]
    assert_equal 2, office_as_json[:services].size
    expected_service_json = {title: 'service-one', type: WorldwideServiceType::AssistanceServices.name}
    assert_equal expected_service_json, office_as_json[:services][0]
    expected_service_json = {title: 'service-two', type: WorldwideServiceType::OtherServices.name}
    assert_equal expected_service_json, office_as_json[:services][1]
  end

  test 'json includes office contact address in offices array' do
    json_formatted_address = {'address' => 'as-json'}
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
