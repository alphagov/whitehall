require 'test_helper'

class AttachmentsControllerTest < ActionController::TestCase
  attr_reader :view_context
  attr_reader :attachment_data
  attr_reader :params
  attr_reader :edition

  setup do
    @view_context = @controller.view_context

    AttachmentUploader.enable_processing = true
    @attachment_data = create(:attachment_data)

    @params = {
      id: attachment_data,
      file: attachment_data.filename_without_extension,
      format: attachment_data.file_extension
    }

    @edition = create(:publication)

    controller.stubs(:attachment_data).returns(attachment_data)

    request.host = 'asset-host.com'
    Plek.any_instance.stubs(:public_asset_host).returns('http://asset-host.com')
  end

  teardown do
    AttachmentUploader.enable_processing = false
  end

  test "redirects asset requests that aren't made via the asset host" do
    request.host = 'not-asset-host.com'

    get :show, params: params

    assert_redirected_to "http://asset-host.com#{attachment_data.file.asset_manager_path}"
  end

  test 'does not redirect asset requests that are made via the asset host' do
    setup_stubs

    request.host = 'asset-host.com'

    get :show, params: params

    assert_response 200
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

  test 'redirects to placeholder image if file is unscanned image' do
    new_file = File.open(fixture_path.join('minister-of-funk.960x640.jpg'))
    attachment_data.update!(file: new_file)
    setup_stubs(file_state: :unscanned)

    get :show, params: params.merge(file: 'minister-of-funk.960x640', format: 'jpg')

    assert_response :found
    assert_redirected_to view_context.path_to_image('thumbnail-placeholder.png')
  end

  test 'redirects to placeholder image if file is unscanned image, even if deleted' do
    new_file = File.open(fixture_path.join('minister-of-funk.960x640.jpg'))
    attachment_data.update!(file: new_file)
    setup_stubs(file_state: :unscanned, deleted?: true)

    get :show, params: params.merge(file: 'minister-of-funk.960x640', format: 'jpg')

    assert_response :found
    assert_redirected_to view_context.path_to_image('thumbnail-placeholder.png')
  end

  test 'redirects to placeholder image if file is unscanned image, even if draft & not accessible' do
    new_file = File.open(fixture_path.join('minister-of-funk.960x640.jpg'))
    attachment_data.update!(file: new_file)
    setup_stubs(file_state: :unscanned, draft?: true, accessible_to?: false)

    get :show, params: params.merge(file: 'minister-of-funk.960x640', format: 'jpg')

    assert_response :found
    assert_redirected_to view_context.path_to_image('thumbnail-placeholder.png')
  end

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

  test 'responds with 404 Not Found if file is infected image' do
    new_file = File.open(fixture_path.join('minister-of-funk.960x640.jpg'))
    attachment_data.update!(file: new_file)
    setup_stubs(file_state: :infected)

    get :show, params: params.merge(file: 'minister-of-funk.960x640', format: 'jpg')

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

  test 'responds with 200 OK for thumbnail if not draft' do
    setup_stubs

    basename = File.basename(attachment_data.file.thumbnail.path, '.png')
    get :show, params: params.merge(file: basename, format: 'png')

    assert_response :ok
  end

  test 'sets Cache-Control header to no-cache if user is signed in' do
    setup_stubs

    get :show, params: params

    assert_cache_control 'no-cache'
  end

  test 'sets Cache-Control header max-age & public directives if user is not signed in' do
    setup_stubs(current_user: nil)

    get :show, params: params

    assert_cache_control 'max-age=14400'
    assert_cache_control 'public'
  end

  test 'sets Link header to parent document URL if it is an edition' do
    setup_stubs

    get :show, params: params

    link_url = public_document_url(edition)
    assert_equal %{<#{link_url}>; rel="up"}, response.headers['Link']
  end

  test 'does not set Link header if parent document is not an edition' do
    setup_stubs(visible_edition: nil)

    get :show, params: params

    assert_nil response.headers['Link']
  end

  test 'streams file to client via Rack::Sendfile' do
    setup_stubs

    get :show, params: params

    assert_equal attachment_data.file.clean_path, response.stream.to_path
  end

  test 'sets Content-Disposition header type to inline' do
    setup_stubs

    get :show, params: params

    disposition_type = response.headers['Content-Disposition'].split(';').first
    assert_equal 'inline', disposition_type
  end

  test 'sets Content-Disposition header filename parameter' do
    setup_stubs

    get :show, params: params

    filename = attachment_data.file.filename
    disposition_param = response.headers['Content-Disposition'].split(';').last
    assert_equal %{filename="#{filename}"}, disposition_param.strip
  end

  test 'sets Content-Type header based on MIME type for file extension' do
    setup_stubs

    get :show, params: params

    assert_equal 'application/pdf', response.headers['Content-Type']
  end

  test 'sets Content-Type header to default value if MIME type not found' do
    new_file = File.open(fixture_path.join('sample.chm'))
    attachment_data.update!(file: new_file)
    setup_stubs

    get :show, params: params.merge(file: 'sample', format: 'chm')

    assert_equal 'application/octet-stream', response.headers['Content-Type']
  end

  test 'sets slimmer template to chromeless' do
    setup_stubs

    get :show, params: params

    assert_equal 'chromeless', response.headers['X-Slimmer-Template']
  end

private

  def setup_stubs(attributes = {})
    file_state = attributes.fetch(:file_state, :clean)
    attributes.delete(:file_state)

    case file_state
    when :clean
      VirusScanHelpers.simulate_virus_scan(attachment_data.file, include_versions: true)
    when :infected
      VirusScanHelpers.simulate_virus_scan_infected(attachment_data.file)
    when :missing
      VirusScanHelpers.erase_test_files
    end

    current_user = attributes.fetch(:current_user, build(:user))
    controller.stubs(:current_user).returns(current_user)
    attributes.delete(:current_user)

    attachment_data.stubs(:accessible_to?).with(current_user)
      .returns(attributes.fetch(:accessible?, false))
    attributes.delete(:accessible?)

    attachment_data.stubs(:visible_edition_for).with(current_user)
      .returns(attributes.fetch(:visible_edition, edition))
    attributes.delete(:visible_edition)

    defaults = {
      deleted?: false,
      unpublished?: false,
      unpublished_edition: nil,
      replaced?: false,
      replaced_by: nil,
      draft?: false,
    }
    attachment_data.stubs(defaults.merge(attributes))
  end
end
