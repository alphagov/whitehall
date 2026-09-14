require "test_helper"

class SingleImageUploadTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  setup do
    @valid_parameters = {
      id: "unique_id",
      name: "foo",
      remove_alt_text_field: true,
    }
  end

  test "requires a name to render" do
    error = assert_raises ActionView::Template::Error do
      render("components/single_image_upload", @valid_parameters.except(:name))
    end

    assert error.message.include?("undefined local variable or method `name'")
  end

  test "requires an id to render" do
    error = assert_raises ActionView::Template::Error do
      render("components/single_image_upload", @valid_parameters.except(:id))
    end

    assert error.message.include?("undefined local variable or method `id'")
  end

  test "renders a single image upload component with default parameters" do
    render("components/single_image_upload", @valid_parameters)

    assert_select ".app-c-single-image-upload.govuk-form-group", count: 1
    assert_select ".app-c-single-image-upload h2", text: "Image (required)"
    assert_select "input[type='file'][name='foo[image]']", count: 1
    assert_select ".app-c-single-image-upload label[for='unique_id_image']", text: "Upload image"
    assert_select ".app-c-single-image-upload .govuk-hint", count: 1, text: "Images must be 960px by 640px"
  end

  test "takes a custom title" do
    render("components/single_image_upload", @valid_parameters.merge({
      title: "Title",
    }))

    assert_select ".app-c-single-image-upload", count: 1
    assert_select ".app-c-single-image-upload h2", text: "Title"
  end

  test "takes a custom image_name" do
    render("components/single_image_upload", @valid_parameters.merge({
      image_name: "custom_image",
    }))

    assert_select "input[type='file'][name='custom_image']", count: 1
  end

  test "takes a custom hint" do
    render("components/single_image_upload", @valid_parameters.merge({
      image_hint: "Custom hint text",
    }))

    assert_select ".app-c-single-image-upload .govuk-hint", count: 1, text: "Custom hint text"
  end

  test "renders the image preview if an image has been uploaded" do
    render("components/single_image_upload", @valid_parameters.merge({
      image_src: "/path/to/image.jpg",
      image_uploaded: true,
    }))

    assert_select ".app-c-single-image-upload img[src='/path/to/image.jpg']", count: 1
  end

  test "changes the call to action to 'Replace image' when an image has been uploaded" do
    render("components/single_image_upload", @valid_parameters.merge({
      image_src: "/path/to/image.jpg",
      image_uploaded: true,
    }))

    assert_select ".app-c-single-image-upload label[for='unique_id_image']", text: "Replace image"
  end

  # TODO: delete when legacy topical events are migrated
  test "does not render an alt text input when alt text is removed" do
    # Whilst the default behaviour is to include the alt text field,
    # it's cleaner to test the alt text behaviour by opting in and
    # asserting selectors. So we explicitly set
    # `remove_alt_text_field: true` in the default parameters in these tests.
    render("components/single_image_upload", @valid_parameters)

    refute_select "input[type='text'][name='foo[image_alt_text]']"
  end

  # TODO: delete when legacy topical events are migrated
  context "when alt text is enabled" do
    test "renders an alt text input" do
      render("components/single_image_upload", @valid_parameters.merge({
        remove_alt_text_field: false,
      }))

      assert_select "input[type='text'][name='foo[image_alt_text]'][id='unique_id_image_alt_text']", count: 1
      assert_select "label[for='unique_id_image_alt_text']", count: 1, text: "Image description (alt text)"
    end

    test "prefills the alt text input when a value is provided" do
      render("components/single_image_upload", @valid_parameters.merge({
        remove_alt_text_field: false,
        image_alt: "Alt text value",
      }))

      assert_select "input[type='text'][value='Alt text value']", count: 1
    end
  end
end
