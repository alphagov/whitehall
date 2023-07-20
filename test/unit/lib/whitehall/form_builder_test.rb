require "test_helper"

class FormBuilderTest < ActionView::TestCase
  setup do
    @object = PromotionalFeatureItem.new
    @builder = Whitehall::FormBuilder.new(:promotional_feature_item, @object, self, {})
  end

  def hidden_image_cache_field(value = "")
    %(<input autocomplete='off' id='promotional_feature_item_image_cache' name='promotional_feature_item[image_cache]' type='hidden' #{value} />)
  end

  def removal_check_box(label_text = "Check to remove image")
    '<div class="checkbox">' \
      '<label for="promotional_feature_item_remove_image">' \
        '<input name="promotional_feature_item[remove_image]" type="hidden" value="0" autocomplete="off" />' \
        '<input id="promotional_feature_item_remove_image" name="promotional_feature_item[remove_image]" type="checkbox" value="1" />' \
        "#{label_text}" \
      "</label>" \
    "</div>"
  end

  test "Whitehall::FormBuilder#upload returns a label and file upload input field, and a hidden cache field by default" do
    expected_html = '<div class="form-group">' \
                      '<label for="promotional_feature_item_image">Image</label>' \
                      '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' \
                      "#{hidden_image_cache_field}" \
                    "</div>"

    assert_dom_equal expected_html, @builder.upload(:image)
  end

  test "Whitehall::FormBuilder#upload includes a removal checkbox if the allow_removal option is true" do
    expected_html = '<div class="form-group">' \
                      '<label for="promotional_feature_item_image">Image</label>' \
                      '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' \
                      "#{hidden_image_cache_field}#{removal_check_box}" \
                    "</div>"

    assert_dom_equal expected_html, @builder.upload(:image, allow_removal: true)
  end

  test "Whitehall::FormBuilder#upload includes a removal checkbox with custom label text if the allow_removal option is true and the allow_removal_label_text is specified" do
    expected_html = '<div class="form-group">' \
                      '<label for="promotional_feature_item_image">Image</label>' \
                      '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' \
                      "#{hidden_image_cache_field}#{removal_check_box('Tick this box to remove image')}" \
                    "</div>"

    assert_dom_equal expected_html, @builder.upload(:image, allow_removal: true, allow_removal_label_text: "Tick this box to remove image")
  end

  test "Whitehall::FormBuilder#upload allows the label text to be overridden" do
    expected_html = '<div class="form-group">' \
                      '<label for="promotional_feature_item_image">Image upload</label>' \
                      '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' \
                      "#{hidden_image_cache_field}" \
                    "</div>"

    assert_dom_equal expected_html, @builder.upload(:image, label_text: "Image upload")
  end

  test "Whitehall::FormBuilder#upload includes upload cache fields if object has a cached file" do
    @object.image = image_fixture_file
    cache_field = hidden_image_cache_field("value = '#{@object.image_cache}'")
    expected_html = '<div class="form-group">' \
                      '<label for="promotional_feature_item_image">Image upload</label>' \
                      '<input id="promotional_feature_item_image" name="promotional_feature_item[image]" type="file" />' \
                      "<span class='already_uploaded'>#{File.basename(image_fixture_file)} already uploaded</span>#{cache_field}" \
                    "</div>"

    assert_dom_equal expected_html, @builder.upload(:image, label_text: "Image upload")
  end

  test "Whitehall::FormBuilder#text_area can produce no label" do
    expected_html = '<div class="form-group">' \
                      '<textarea class="form-control" name="promotional_feature_item[summary]" id="promotional_feature_item_summary">
</textarea></div>'

    assert_dom_equal expected_html, @builder.text_area(:summary, label: false)
  end
end
