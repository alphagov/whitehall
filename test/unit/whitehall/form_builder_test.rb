require 'test_helper'

class FormBuilderTest < ActionView::TestCase

  setup do
    @object = PromotionalFeatureItem.new
    @builder = Whitehall::FormBuilder.new(:promotional_feature_item, @object, self, {}, nil)
  end

  test 'Whitehall::FormBuilder#upload returns a label and file upload input field by default' do
    expected_html = '<label for="promotional_feature_item_image">Image</label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />'

    assert_dom_equal expected_html, @builder.upload(:image)
  end

  test 'Whitehall::FormBuilder#upload allows the label text to be overridden' do
    expected_html = '<label for="promotional_feature_item_image">Image upload</label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />'

    assert_dom_equal expected_html, @builder.upload(:image, label_text: "Image upload")
  end

  test 'Whitehall::FormBuilder#upload includes upload cache fields if object has a cached file' do
    @object.image = image_fixture_file
    expected_html = '<label for="promotional_feature_item_image">Image upload</label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' +
                    "<span class='already_uploaded'>#{File.basename(image_fixture_file)} already uploaded</span>" +
                     "<input id='promotional_feature_item_image_cache' name='promotional_feature_item[image_cache]' type='hidden' value='#{@object.image_cache}' />"

    assert_dom_equal expected_html, @builder.upload(:image, label_text: "Image upload")
  end

  test 'Whitehall::FormBuilder#upload renders a horizontal version' do
    expected_html = '<div class="control-group">' +
                      '<label for="promotional_feature_item_image" class="control-label">Image</label>' +
                      '<div class="controls">' +
                        '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' +
                      '</div>' +
                    '</div>'

    assert_dom_equal expected_html, @builder.upload(:image, horizontal: true)
  end

  test 'Whitehall::FormBuilder#upload renders a horizontal version with cache fields' do
    @object.image = image_fixture_file
    expected_html = '<div class="control-group">' +
                      '<label for="promotional_feature_item_image" class="control-label">Image</label>' +
                      '<div class="controls">' +
                        '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' +
                        "<span class='already_uploaded'>#{File.basename(image_fixture_file)} already uploaded</span>" +
                        "<input id='promotional_feature_item_image_cache' name='promotional_feature_item[image_cache]' type='hidden' value='#{@object.image_cache}' />" +
                      '</div>' +
                    '</div>'
    assert_dom_equal expected_html, @builder.upload(:image, horizontal: true)
  end
end
