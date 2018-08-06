require 'test_helper'

class UploadAccessTest < ActionDispatch::IntegrationTest
  def get_via_nginx(path)
    get path, params: {}, headers: {
      "HTTP_X_SENDFILE_TYPE" => "X-Accel-Redirect",
      "HTTP_X_ACCEL_MAPPING" => "#{Whitehall.clean_uploads_root}/=/clean-uploads/"
    }
  end

  def asset_host
    URI.parse(Plek.new.public_asset_host).host
  end

  setup do
    host! asset_host
  end

  test 'redirects all non-attachment, non-hmrc asset requests to the asset host' do
    upload = '/government/uploads/general-upload.jpg'

    get_via_nginx upload

    assert_redirected_to "http://#{asset_host}/government/uploads/general-upload.jpg"
  end

  test 'redirects requests for files with uppercase names (as well as lowercase)' do
    upload = '/government/uploads/GENERAL-UPLOAD.JPG'

    get_via_nginx upload

    assert_redirected_to "http://#{asset_host}/government/uploads/GENERAL-UPLOAD.JPG"
  end

  test 'redirects all attachment requests to the asset host' do
    upload = '/government/uploads/system/uploads/attachment_data/file/123/attachment.pdf'

    get_via_nginx upload

    assert_redirected_to "http://#{asset_host}/government/uploads/system/uploads/attachment_data/file/123/attachment.pdf"
  end
end
