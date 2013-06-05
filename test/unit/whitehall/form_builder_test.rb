require 'test_helper'

class FormBuilderTest < ActionView::TestCase

  setup do
    @object = PromotionalFeatureItem.new
    @builder = Whitehall::FormBuilder.new(:promotional_feature_item, @object, self, {}, nil)
  end

  def hidden_image_cache_field(value = '')
    %(<input id='promotional_feature_item_image_cache' name='promotional_feature_item[image_cache]' type='hidden' #{value} />)
  end

  def removal_check_box(label_text = 'Check to remove image')
    %(<label class="checkbox" for="promotional_feature_item_remove_image">) +
      %(<input name="promotional_feature_item[remove_image]" type="hidden" value="0" />) +
      %(<input id="promotional_feature_item_remove_image" name="promotional_feature_item[remove_image]" type="checkbox" value="1" />) +
      label_text +
    %(</label>)
  end

  test 'Whitehall::FormBuilder#upload returns a label and file upload input field, and a hidden cache field by default' do
    expected_html = '<label class="required" for="promotional_feature_item_image">Image<span>*</span></label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required" type="file" />' +
                    hidden_image_cache_field

    assert_dom_equal expected_html, @builder.upload(:image)
  end

  test 'Whitehall::FormBuilder#upload includes a removal checkbox if the allow_removal option is true' do
    expected_html = '<label class="required" for="promotional_feature_item_image">Image<span>*</span></label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required" type="file" />' +
                    hidden_image_cache_field +
                    removal_check_box

    assert_dom_equal expected_html, @builder.upload(:image, allow_removal: true)
  end

  test 'Whitehall::FormBuilder#upload includes a removal checkbox with custom label text if the allow_removal option is true and the allow_removal_label_text is specified' do
    expected_html = '<label class="required" for="promotional_feature_item_image">Image<span>*</span></label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required" type="file" />' +
                    hidden_image_cache_field +
                    removal_check_box('Tick this box to remove image')

    assert_dom_equal expected_html, @builder.upload(:image, allow_removal: true, allow_removal_label_text: 'Tick this box to remove image')
  end

  test 'Whitehall::FormBuilder#upload allows the label text to be overridden' do
    expected_html = '<label class="required" for="promotional_feature_item_image">Image upload<span>*</span></label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required" type="file" />' +
                    hidden_image_cache_field

    assert_dom_equal expected_html, @builder.upload(:image, label_text: "Image upload")
  end

  test 'Whitehall::FormBuilder#upload includes upload cache fields if object has a cached file' do
    @object.image = image_fixture_file
    expected_html = '<label class="required" for="promotional_feature_item_image">Image upload<span>*</span></label>' +
                    '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required" type="file" />' +
                    "<span class='already_uploaded'>#{File.basename(image_fixture_file)} already uploaded</span>" +
                    hidden_image_cache_field("value = '#{@object.image_cache}'")

    assert_dom_equal expected_html, @builder.upload(:image, label_text: "Image upload")
  end


  test 'Whitehall::FormBuilder#upload renders a horizontal version' do
    expected_html = '<div class="control-group">' +
                      '<label class="control-label required" for="promotional_feature_item_image">Image<span>*</span></label>' +
                      '<div class="controls">' +
                        '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required" type="file" />' +
                        hidden_image_cache_field +
                      '</div>' +
                    '</div>'

    assert_dom_equal expected_html, @builder.upload(:image, horizontal: true)
  end

  test 'Whitehall::FormBuilder#upload renders a horizontal version with cache fields' do
    @object.image = image_fixture_file
    expected_html = '<div class="control-group">' +
                      '<label for="promotional_feature_item_image" class="control-label required">Image<span>*</span></label>' +
                      '<div class="controls">' +
                        '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required"  type="file" />' +
                        "<span class='already_uploaded'>#{File.basename(image_fixture_file)} already uploaded</span>" +
                        "<input id='promotional_feature_item_image_cache' name='promotional_feature_item[image_cache]' type='hidden' value='#{@object.image_cache}' />" +
                      '</div>' +
                    '</div>'
    assert_dom_equal expected_html, @builder.upload(:image, horizontal: true)
  end

  test 'Whitehall::FormBuilder#upload renders a horizontal version with a removal checkbox, if asked to' do
    @object.image = image_fixture_file
    expected_html = '<div class="control-group">' +
                      '<label for="promotional_feature_item_image" class="control-label required">Image<span>*</span></label>' +
                      '<div class="controls">' +
                        '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" required="required" type="file" />' +
                        "<span class='already_uploaded'>#{File.basename(image_fixture_file)} already uploaded</span>" +
                        "<input id='promotional_feature_item_image_cache' name='promotional_feature_item[image_cache]' type='hidden' value='#{@object.image_cache}' />" +
                        removal_check_box +
                      '</div>' +
                    '</div>'
    assert_dom_equal expected_html, @builder.upload(:image, horizontal: true, allow_removal: true)
  end
end
