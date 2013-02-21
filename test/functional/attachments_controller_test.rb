require "test_helper"

class AttachmentsControllerTest < ActionController::TestCase
  test 'attachment documents that aren\'t visible and haven\'t been replaced are redirected to the placeholder url' do
    ad = create(:attachment_data)
    @controller.stubs(:attachment_visible?).with(ad.to_param).returns false

    get :show, id: ad.to_param, file: 'uk-cheese-consumption-figures-2011', extension: 'pdf'

    assert_redirected_to placeholder_url
  end

  test 'attachment images that aren\'t visible and haven\'t been replaced are redirected to the placeholder image' do
    ad = create(:attachment_data)
    @controller.stubs(:attachment_visible?).with(ad.to_param).returns false

    get :show, id: ad.to_param, file: 'uk-cheese-consumption-figures-2011-chart', extension: 'jpg'

    assert_redirected_to @controller.view_context.path_to_image('thumbnail-placeholder.png')
  end

  test 'attachments that aren\'t visible and haven\'t been replaced are redirected to the placeholder image' do
    replacement = create(:attachment_data)
    ad = create(:attachment_data, replaced_by: replacement)
    @controller.stubs(:attachment_visible?).with(ad.to_param).returns false

    get :show, id: ad.to_param, file: 'uk-cheese-consumption-figures-2011-chart', extension: 'pdf'

    assert_redirected_to replacement.url
  end

  test 'attachments that are visible are sent to the browser' do
    Whitehall.stubs(:clean_upload_path).returns(Rails.root.join('test','clean-uploads'))
    begin
      ad = create(:attachment_data)
      @controller.stubs(:attachment_visible?).with(ad.to_param).returns true

      FileUtils.mkdir_p(Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad.to_param}/")
      FileUtils.cp(Rails.root.join('test','fixtures','whitepaper.pdf'), Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad.to_param}/uk-cheese-consumption-figures-2011.pdf")

      get :show, id: ad.to_param, file: 'uk-cheese-consumption-figures-2011', extension: 'pdf'

      assert_response :success
    ensure
      FileUtils.rmtree(Whitehall.clean_upload_path)
    end
  end

  test 'attachments on policy groups are always visible' do
    Whitehall.stubs(:clean_upload_path).returns(Rails.root.join('test','clean-uploads'))
    begin
      ad = create(:policy_group_attachment)

      ad_param = ad.attachment.attachment_data.to_param

      FileUtils.mkdir_p(Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad_param}/")
      FileUtils.cp(Rails.root.join('test','fixtures','whitepaper.pdf'), Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad_param}/uk-cheese-consumption-figures-2011.pdf")

      get :show, id: ad_param, file: 'uk-cheese-consumption-figures-2011', extension: 'pdf'

      assert_response :success
    ensure
      FileUtils.rmtree(Whitehall.clean_upload_path)
    end
  end

  test 'attachments that are images are sent inline' do
    Whitehall.stubs(:clean_upload_path).returns(Rails.root.join('test','clean-uploads'))
    begin
      ad = create(:attachment_data)
      @controller.stubs(:attachment_visible?).with(ad.to_param).returns true

      FileUtils.mkdir_p(Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad.to_param}/")
      FileUtils.cp(Rails.root.join('test','fixtures','minister-of-funk.960x640.jpg'), Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad.to_param}/minister-of-funk.960x640.jpg")

      get :show, id: ad.to_param, file: 'minister-of-funk.960x640', extension: 'jpg'

      assert_response :success
      assert_match /^inline;/, response.headers['Content-Disposition']
    ensure
      FileUtils.rmtree(Whitehall.clean_upload_path)
    end
  end

  test 'attachments that are documents are sent inline' do
    Whitehall.stubs(:clean_upload_path).returns(Rails.root.join('test','clean-uploads'))
    begin
      ad = create(:attachment_data)
      @controller.stubs(:attachment_visible?).with(ad.to_param).returns true

      FileUtils.mkdir_p(Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad.to_param}/")
      FileUtils.cp(Rails.root.join('test','fixtures','whitepaper.pdf'), Whitehall.clean_upload_path + "system/uploads/attachment_data/file/#{ad.to_param}/uk-cheese-consumption-figures-2011.pdf")

      get :show, id: ad.to_param, file: 'uk-cheese-consumption-figures-2011', extension: 'pdf'

      assert_response :success
      assert_match /^inline;/, response.headers['Content-Disposition']
    ensure
      FileUtils.rmtree(Whitehall.clean_upload_path)
    end
  end
end
