require 'test_helper'

class CsvPreviewControllerTest < ActionController::TestCase
  attr_reader :attachment_data
  attr_reader :params
  attr_reader :organisation_1
  attr_reader :organisation_2
  attr_reader :edition
  attr_reader :attachment
  attr_reader :file

  setup do
    @file = File.open(fixture_path.join('sample.csv'))
    @attachment_data = create(:attachment_data, file: file)
    FileUtils.rm(@attachment_data.file.path)

    @params = {
      id: attachment_data,
      file: attachment_data.filename_without_extension,
      extension: attachment_data.file_extension
    }

    @organisation_1 = create(:organisation)
    @organisation_2 = create(:organisation)
    @edition = create(:publication, organisations: [organisation_1, organisation_2])
    @attachment = build(:file_attachment)

    controller.stubs(:attachment_data).returns(attachment_data)
  end

  # Unpublished

  test 'redirects to unpublished edition if attachment data is unpublished & deleted' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(deleted?: true, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :found
    assert_redirected_to unpublished_edition.unpublishing.document_path
  end

  test 'redirects to unpublished edition if attachment data is unpublished & unscanned' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(file_state: :unscanned, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :found
    assert_redirected_to unpublished_edition.unpublishing.document_path
  end

  test 'redirects to unpublished edition if attachment data is unpublished & infected' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(file_state: :infected, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :found
    assert_redirected_to unpublished_edition.unpublishing.document_path
  end

  test 'redirects to unpublished edition if attachment data is unpublished & missing' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(file_state: :missing, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :found
    assert_redirected_to unpublished_edition.unpublishing.document_path
  end

  test 'redirects to unpublished edition if attachment data is unpublished & not a CSV' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(csv?: false, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :found
    assert_redirected_to unpublished_edition.unpublishing.document_path
  end

  test 'redirects to unpublished edition if attachment data is unpublished, draft & not accessible' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(draft?: true, accessible_to?: false, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :found
    assert_redirected_to unpublished_edition.unpublishing.document_path
  end

  test 'redirects to unpublished edition if attachment data is unpublished, deleted & replaced' do
    unpublished_edition = create(:unpublished_edition)
    replacement = create(:attachment_data)
    setup_stubs(deleted?: true, unpublished?: true, unpublished_edition: unpublished_edition, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :found
    assert_redirected_to unpublished_edition.unpublishing.document_path
  end

  # Replaced

  test 'permanently redirects to replacement if attachment data is replaced & deleted' do
    replacement = create(:attachment_data)
    setup_stubs(deleted?: true, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :moved_permanently
    assert_redirected_to replacement.url
  end

  test 'permanently redirects to replacement if attachment data is replaced & unscanned' do
    replacement = create(:attachment_data)
    setup_stubs(file_state: :unscanned, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :moved_permanently
    assert_redirected_to replacement.url
  end

  test 'permanently redirects to replacement if attachment data is replaced & infected' do
    replacement = create(:attachment_data)
    setup_stubs(file_state: :infected, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :moved_permanently
    assert_redirected_to replacement.url
  end

  test 'permanently redirects to replacement if attachment data is replaced & missing' do
    replacement = create(:attachment_data)
    setup_stubs(file_state: :missing, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :moved_permanently
    assert_redirected_to replacement.url
  end

  test 'permanently redirects to replacement if attachment data is replaced & not CSV' do
    replacement = create(:attachment_data)
    setup_stubs(csv?: false, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :moved_permanently
    assert_redirected_to replacement.url
  end

  test 'permanently redirects to replacement if attachment data is replaced, draft & not accessible' do
    replacement = create(:attachment_data)
    setup_stubs(draft?: true, accessible_to?: false, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :moved_permanently
    assert_redirected_to replacement.url
  end

  test 'sets Cache-Control header to no-cache if redirecting to replacement' do
    replacement = create(:attachment_data)
    setup_stubs(deleted?: true, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_cache_control 'no-cache'
  end

  test 'sets Cache-Control header max-age & public directives if redirecting to replacement' do
    replacement = create(:attachment_data)
    setup_stubs(current_user: nil, deleted?: true, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_cache_control 'max-age=14400'
    assert_cache_control 'public'
  end

  # Unscanned

  test 'redirects to placeholder page if file is unscanned non-image' do
    setup_stubs(file_state: :unscanned)

    get :show, params: params

    assert_response :found
    assert_redirected_to placeholder_url
  end

  test 'sets Cache-Control header max-age & public directives if unscanned non-image' do
    setup_stubs(file_state: :unscanned)

    get :show, params: params

    assert_cache_control 'max-age=60'
    assert_cache_control 'public'
  end

  test 'redirects to placeholder page if file is unscanned non-image even if deleted' do
    setup_stubs(file_state: :unscanned, deleted?: true)

    get :show, params: params

    assert_response :found
    assert_redirected_to placeholder_url
  end

  test 'redirects to placeholder page if file is unscanned non-image even if not CSV' do
    setup_stubs(file_state: :unscanned, csv?: false)

    get :show, params: params

    assert_response :found
    assert_redirected_to placeholder_url
  end

  test 'redirects to placeholder page if file is unscanned non-image even if draft & not accessible' do
    setup_stubs(file_state: :unscanned, draft?: true, accessible_to?: false)

    get :show, params: params

    assert_response :found
    assert_redirected_to placeholder_url
  end

  # Not found

  test 'responds with 404 Not Found if attachment data does not exist' do
    setup_stubs
    controller.stubs(:attachment_data).raises(ActiveRecord::RecordNotFound)

    assert_raises(ActiveRecord::RecordNotFound) { get :show, params: params }
  end

  test 'responds with 404 Not Found if file does not exist' do
    setup_stubs(file_state: :missing)

    get :show, params: params

    assert_response :not_found
  end

  test 'responds with 404 Not Found if file is infected' do
    setup_stubs(file_state: :infected)

    get :show, params: params

    assert_response :not_found
  end

  test 'responds with 404 Not Found if attachment data is deleted' do
    setup_stubs(deleted?: true)

    get :show, params: params

    assert_response :not_found
  end

  test 'responds with 404 Not Found if attachment data is draft and not accessible to user' do
    setup_stubs(draft?: true, accessible?: false)

    get :show, params: params

    assert_response :not_found
  end

  test 'responds with 404 Not Found if attachment data is not CSV' do
    setup_stubs(csv?: false)

    get :show, params: params

    assert_response :not_found
  end

  test 'responds with 404 Not Found if no parent edition' do
    setup_stubs(visible_edition: nil)

    get :show, params: params

    assert_response :not_found
  end

  # OK

  test 'responds with 200 OK if attachment data is draft and accessible to user' do
    setup_stubs(draft?: true, accessible?: true)

    get :show, params: params

    assert_response :ok
  end

  test 'responds with 200 OK if not draft' do
    setup_stubs

    get :show, params: params

    assert_response :ok
  end

  test 'responds with 200 OK if attachment data is draft & accessible, even if unpublished' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(draft?: true, accessible?: true, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :ok
  end

  test 'responds with 200 OK if attachment data is not draft, even if unpublished' do
    unpublished_edition = create(:unpublished_edition)
    setup_stubs(draft?: false, unpublished?: true, unpublished_edition: unpublished_edition)

    get :show, params: params

    assert_response :ok
  end

  test 'responds with 200 OK if attachment data is draft & accessible, even if replaced' do
    replacement = create(:attachment_data)
    setup_stubs(draft?: true, accessible?: true, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :ok
  end

  test 'responds with 200 OK if attachment data is not draft, even if replaced' do
    replacement = create(:attachment_data)
    setup_stubs(draft?: false, replaced?: true, replaced_by: replacement)

    get :show, params: params

    assert_response :ok
  end

  test 'sets Cache-Control header to no-cache if user is signed in' do
    setup_stubs

    get :show, params: params

    assert_cache_control 'no-cache'
  end

  test 'sets Cache-Control header max-age directive if user is not signed in' do
    setup_stubs(current_user: nil)

    get :show, params: params

    assert_cache_control 'max-age=14400'
  end

  test 'sets Cache-Control header public directive if user is not signed in' do
    setup_stubs(current_user: nil)

    get :show, params: params

    assert_cache_control 'public'
  end

  test 'sets slimmer template to chromeless' do
    setup_stubs

    get :show, params: params

    assert_equal 'chromeless', response.headers['X-Slimmer-Template']
  end

  test 'renders show template with html attachments layout' do
    setup_stubs

    get :show, params: params

    assert_template 'show', layout: 'html_attachments'
  end

  test 'raises ActionController::UnknownFormat if format is unknown' do
    setup_stubs

    assert_raises(ActionController::UnknownFormat) do
      get :show, params: params.merge(format: 'pdf')
    end
  end

  test 'raises ActionController::UnknownFormat for XHR request if format is unknown' do
    setup_stubs

    assert_raises(ActionController::UnknownFormat) do
      get :show, params: params.merge(format: 'pdf'), xhr: true
    end
  end

  test 'assigns edition for template' do
    setup_stubs

    get :show, params: params

    assert_equal edition, assigns(:edition)
  end

  test 'assigns attachment for template' do
    setup_stubs

    get :show, params: params

    assert_equal attachment, assigns(:attachment)
  end

  test 'assigns csv preview for template' do
    setup_stubs

    get :show, params: params

    assert_instance_of CsvPreview, assigns(:csv_preview)
  end

  view_test 'renders attachment title as heading' do
    setup_stubs

    get :show, params: params

    assert_select '.headings h1', attachment.title
  end

  view_test 'renders links to edition organisations' do
    setup_stubs

    get :show, params: params

    assert_select 'a[href=?]', organisation_path(organisation_1)
    assert_select 'a[href=?]', organisation_path(organisation_2)
  end

  view_test 'renders CSV column headings' do
    setup_stubs

    get :show, params: params

    assert_select 'div.csv-preview th:nth-child(1)', text: 'Department'
    assert_select 'div.csv-preview th:nth-child(2)', text: 'Budget'
    assert_select 'div.csv-preview th:nth-child(3)', text: 'Amount spent'
  end

  view_test 'renders CSV cell values' do
    setup_stubs

    get :show, params: params

    assert_select 'div.csv-preview td:nth-child(1)', text: 'Office for Facial Hair Studies'
    assert_select 'div.csv-preview td:nth-child(2)', text: '£12000000'
    assert_select 'div.csv-preview td:nth-child(3)', text: '£10000000'
  end

  view_test 'renders error message if csv_preview is nil' do
    setup_stubs(csv_preview: nil)

    get :show, params: params

    assert_select 'p.preview-error', text: /This file could not be previewed/
  end

private

  def setup_stubs(attributes = {})
    file_state = attributes.fetch(:file_state, :clean)
    attributes.delete(:file_state)

    current_user = attributes.fetch(:current_user, build(:user))
    controller.stubs(:current_user).returns(current_user)
    attributes.delete(:current_user)

    attachment_data.stubs(:accessible_to?).with(current_user)
      .returns(attributes.fetch(:accessible?, false))
    attributes.delete(:accessible?)

    attachment_data.stubs(:visible_edition_for).with(current_user)
      .returns(attributes.fetch(:visible_edition, edition))
    attributes.delete(:visible_edition)

    attachment_data.stubs(:visible_attachment_for).with(current_user)
      .returns(attributes.fetch(:visible_attachment, attachment))
    attributes.delete(:visible_attachment)

    csv_preview = attributes.fetch(:csv_preview, CsvPreview.new(file))
    csv_response = stub('csv-response')

    case file_state
    when :clean
      csv_response.stubs(:status).returns(206)
    when :infected, :missing
      csv_response.stubs(:status).returns(404)
    when :unscanned
      csv_response.stubs(:status).returns(302)
      csv_response.stubs(:headers).returns('Location' => 'http://www.example.com/government/placeholder')
    end

    CsvFileFromPublicHost.stubs(:csv_response)
      .with(attachment_data.file.asset_manager_path)
      .returns(csv_response)
    CsvFileFromPublicHost.stubs(:csv_preview_from)
      .with(csv_response)
      .returns(csv_preview)
    attributes.delete(:csv_preview)

    defaults = {
      deleted?: false,
      unpublished?: false,
      unpublished_edition: nil,
      replaced?: false,
      replaced_by: nil,
      draft?: false,
      csv?: true
    }

    attachment_data.stubs(defaults.merge(attributes))
  end
end
