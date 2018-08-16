require 'test_helper'

class UploadAccessTest < ActionDispatch::IntegrationTest
  def asset_host
    URI.parse(Plek.new.public_asset_host).host
  end

  setup do
    host! asset_host
  end

  test 'redirects all non-attachment, non-hmrc asset requests to the asset host' do
    upload = '/government/uploads/general-upload.jpg'

    get upload

    assert_redirected_to "http://#{asset_host}/government/uploads/general-upload.jpg"
  end

  test 'redirects requests for files with uppercase names (as well as lowercase)' do
    upload = '/government/uploads/GENERAL-UPLOAD.JPG'

    get upload

    assert_redirected_to "http://#{asset_host}/government/uploads/GENERAL-UPLOAD.JPG"
  end

  test 'redirects all attachment requests to the asset host' do
    upload = '/government/uploads/system/uploads/attachment_data/file/123/attachment.pdf'

    get upload

    assert_redirected_to "http://#{asset_host}/government/uploads/system/uploads/attachment_data/file/123/attachment.pdf"
  end
end
