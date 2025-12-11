require "test_helper"

class Admin::StandardEditionImagesControllerTest < ActionController::TestCase
  setup do
    io_object = upload_fixture("minister-of-funk.960x640.jpg").tempfile.to_io
    stub_request(:get, %r{.*/media/.*/minister-of-funk.960x640.jpg}).to_return(status: 200, body: io_object, headers: {})

    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "properties" => {
          "body" => {
            "title" => "Body (required)",
            "type" => "string",
            "format" => "govspeak",
          },
        },
      },
      "settings" => {
        "edit_screens" => {
          "document" => %w[body],
        },
        "images" => {
          "enabled" => true,
          "permitted_image_kinds" => ["header", "logo"]
        }
      },
    }))
  end

  view_test "edit page shows image editing form for each image kind" do
    image_kinds = Whitehall::ImageKinds.build_image_kinds(
      "header" => {
        "display_name" => "test image kind",
        "valid_width" => 1,
        "valid_height" => 2,
        "permitted_uses" => ["header"],
        "versions" => [
          {
            "name" => "default",
            "width" => 1,
            "height" => 2,
          }
        ],
      },
      "logo" => {
        "display_name" => "test image kind",
        "valid_width" => 1,
        "valid_height" => 2,
        "permitted_uses" => ["logo"],
        "versions" => [
          {
            "name" => "default",
            "width" => 1,
            "height" => 2,
          }
        ],
      }
    )
    login_authorised_user
    image = build(:image)
    edition = create(:draft_standard_edition, images: [image])

    get :index, params: { standard_edition_id: edition.id }
    assert_select "form[action='#{admin_standard_edition_images_path(edition)}'][method='post']"
    assert_select "h2", text: "Upload an #{image_kinds["header"].display_name} image"
  end

  def login_authorised_user
    user = create(:gds_editor)
    login_as user
  end
end
