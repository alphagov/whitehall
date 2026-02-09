require "test_helper"

class Admin::EditionImagesControllerTest < ActionController::TestCase
  setup do
    io_object = upload_fixture("minister-of-funk.960x640.jpg").tempfile.to_io
    stub_request(:get, %r{.*/media/.*/minister-of-funk.960x640.jpg}).to_return(status: 200, body: io_object, headers: {})
  end

  view_test "GET :index renders link to upload form for single image usage" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "header" => {
              "label" => "header",
              "kinds" => %w[topical_event_header],
              "multiple" => false,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition, configurable_document_type: "test_type")

    get :index, params: { edition_id: edition.id }

    assert_select "#uploaded_header_image_card a[href=\"/government/admin/editions/#{edition.id}/images/new?image_usage=header\"]"
  end

  view_test "GET :index page renders image for single image usage if present" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "header" => {
              "label" => "header",
              "kinds" => %w[topical_event_header],
              "multiple" => false,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition, configurable_document_type: "test_type", images: [
      create(:image, usage: "header"),
    ])

    get :index, params: { edition_id: edition.id }

    assert_select "#uploaded_header_image_card img"
    assert_select "#uploaded_header_image_card a[href=\"/government/admin/editions/#{edition.id}/images/new?image_usage=header\"]", count: 0
  end

  view_test "GET :index page renders upload form and existing images for multiple image usage" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "header" => {
              "label" => "header",
              "kinds" => %w[topical_event_header],
              "multiple" => true,
            },
          },
        },
      },
    }))
    image = create(:image, usage: "header")
    edition = create(:draft_standard_edition, configurable_document_type: "test_type", images: [image])

    get :index, params: { edition_id: edition.id }

    assert_select "#header_image_upload_form"
    assert_select "h2", text: "Uploaded header images"
    assert_select "img[src=?]", image.thumbnail
  end

  view_test "GET :index page renders upload form, embedding guidance and existing images for govspeak embed image usage" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "govspeak_embed" => {
              "kinds" => %w[default],
              "multiple" => true,
            },
          },
        },
      },
    }))
    image = create(:image, usage: "govspeak_embed")
    edition = create(:draft_standard_edition, configurable_document_type: "test_type", images: [image])

    get :index, params: { edition_id: edition.id }

    assert_select "#govspeak_embed_image_upload_form"
    assert_select "h2", text: "Uploaded images"
    assert_select "h2", text: "Images available to use in document"
    assert_select ".govuk-inset-text", text: "Copy the image markdown code to add images to the document body."
    assert_select "img[src=?]", image.thumbnail
  end

  view_test "GET :index page renders standard edition images upload form alongside custom image block, and govspeak embed images list" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "images" => {
          "fields" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "block" => "default_string",
            },
          },
        },
      },
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "govspeak_embed" => {
              "kinds" => %w[default],
              "multiple" => true,
            },
          },
        },
      },
    }))
    image = create(:image, usage: "govspeak_embed")
    edition = create(:draft_standard_edition, configurable_document_type: "test_type", images: [image])

    get :index, params: { edition_id: edition.id }

    assert_select "#govspeak_embed_image_upload_form"
    assert_select "label", text: "Test attribute"
    assert_select "h2", text: "Uploaded images"
    assert_select "img[src=?]", image.thumbnail
  end

  view_test "GET :edit page shows image editing form" do
    login_authorised_user
    image = build(:image)
    edition = create(:draft_publication, images: [image])
    get :edit, params: { edition_id: edition.id, id: image.id }
    assert_select "form[action='#{admin_edition_image_path(edition, image)}'][method='post']"
  end

  view_test "GET: edit page shows image if all its assets are uploaded" do
    login_authorised_user
    image = build(:image)
    edition = create(:draft_publication, images: [image])

    get :edit, params: { edition_id: edition.id, id: image.id }

    assert_select "img:match('src',?)", /.*data:image.*/
  end

  view_test "GET: edit page shows processing label if some of the image assets haven't finished processing" do
    login_authorised_user
    image = build(:image_with_no_assets)
    edition = create(:draft_publication, images: [image])

    get :edit, params: { edition_id: edition.id, id: image.id }

    assert_select "span[class='govuk-tag govuk-tag--green']", text: "Processing", count: 1
  end

  view_test "GET :new redirects if image usage only allows single upload and an image has been uploaded" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "header" => {
              "label" => "header",
              "kinds" => %w[topical_event_header],
              "multiple" => false,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition, configurable_document_type: "test_type", images: [
      create(:image, usage: "header"),
    ])

    get :new, params: { edition_id: edition.id, image_usage: "header" }

    assert_redirected_to admin_edition_images_path(edition)
  end

  test "POST :create uploads one valid 'single' usage image, and redirects to 'edit'" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "hero" => {
              "label" => "hero",
              "kinds" => %w[hero_mobile],
              "multiple" => false,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition)
    file = upload_fixture("hero_image_mobile_2x.png")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id, false).once

    post :create, params: { edition_id: edition.id, usage: "hero", image_kind: "hero_mobile", images: [{ image_data_attributes: { file: } }] }

    assert_redirected_to edit_admin_edition_image_path(edition, edition.images.first.id)
  end

  test "POST :create uploads one valid 'multiple' usage embeddable image, and redirect to 'edit'" do
    login_authorised_user
    edition = create(:draft_case_study)
    file = upload_fixture("images/960x640_jpeg.jpg")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id, false).once

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: [{ image_data_attributes: { file: } }] }

    assert_redirected_to edit_admin_edition_image_path(edition, edition.images.first.id)
  end

  test "POST :create uploads one valid 'multiple' usage non-embeddable image, and redirects to 'edit'" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "hero" => {
              "label" => "hero",
              "kinds" => %w[hero_mobile],
              "multiple" => true,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition)
    file = upload_fixture("hero_image_mobile_2x.png")
    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id, false).once

    post :create, params: { edition_id: edition.id, usage: "hero", image_kind: "hero_mobile", images: [{ image_data_attributes: { file: } }] }

    assert_redirected_to edit_admin_edition_image_path(edition, edition.images.first.id)
  end

  test "POST :create uploads many valid 'multiple' usage embeddable images, and redirects to `index`" do
    login_authorised_user
    edition = create(:draft_case_study)
    files = [upload_fixture("images/960x640_jpeg.jpg"), upload_fixture("minister-of-funk.960x640.jpg")]
    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id, false).once

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: files.map { |file| { image_data_attributes: { file: } } } }

    assert_template "admin/edition_images/index"
    assert_equal "Images successfully uploaded", flash[:notice]
  end

  test "POST :create uploads many valid 'multiple' usage non-embeddable images, and redirects to `index`" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "hero" => {
              "label" => "hero",
              "kinds" => %w[hero_mobile],
              "multiple" => true,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition)
    # Both these images' size is valid for hero_mobile kind.
    files = [upload_fixture("hero_image_mobile_2x.png"), upload_fixture("hero_image_tablet_2x.png")]

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id, false).once

    post :create, params: { edition_id: edition.id, usage: "hero", image_kind: "hero_mobile", images: files.map { |file| { image_data_attributes: { file: } } } }

    assert_template "admin/edition_images/index"
    assert_equal "Images successfully uploaded", flash[:notice]
  end

  test "POST :create with no file selection redirects to the index page with no error, nor notice" do
    login_authorised_user
    edition = create(:draft_case_study)

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: [] }

    assert_template "admin/edition_images/index"
    assert_nil flash[:notice]
    assert_nil flash[:error]
  end

  view_test "POST :create shows a validation error if one 'single' usage image is too small, using the 'new' template" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "header" => {
              "label" => "header",
              "kinds" => %w[topical_event_header],
              "multiple" => false,
            },
          },
        },
      },
    }))
    file = upload_fixture("images/50x33_gif.gif")
    edition = create(:draft_standard_edition, configurable_document_type: "test_type")

    post :create, params: { edition_id: edition.id, usage: "header", image_kind: "topical_event_header", images: [{ image_data_attributes: { file: } }] }

    topical_event_header_kind = Whitehall.image_kinds.fetch("topical_event_header")
    assert_template "admin/edition_images/new"
    assert_select ".govuk-error-summary li", "Image data file is too small. Select an image that is at least #{topical_event_header_kind.valid_width} pixels wide and at least #{topical_event_header_kind.valid_height} pixels tall"
  end

  view_test "POST :create shows a validation error if one 'single' usage image has a duplicated filename, using the 'new' template" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "header" => {
              "label" => "header",
              "kinds" => %w[topical_event_header],
              "multiple" => false,
            },
          },
        },
      },
    }))
    file = upload_fixture("images/test-svg.svg")
    image = create(:image, usage: "header", image_data: build(:image_data, file:))
    edition = create(:draft_standard_edition, configurable_document_type: "test_type", images: [image])

    post :create, params: { edition_id: edition.id, usage: "header", image_kind: "topical_event_header", images: [{ image_data_attributes: { file: } }] }

    assert_template "admin/edition_images/new"
    assert_select ".govuk-error-summary li", "Image data file name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name."
  end

  view_test "POST :create shows a validation error if one 'multiple' usage embeddable image is too small, using the 'index' template" do
    login_authorised_user
    edition = create(:draft_case_study)
    file = upload_fixture("images/50x33_gif.gif")

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: [{ image_data_attributes: { file: } }] }

    default_kind = Whitehall.image_kinds.fetch("default")
    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file is too small. Select an image that is at least #{default_kind.valid_width} pixels wide and at least #{default_kind.valid_height} pixels tall"
  end

  view_test "POST :create shows a validation error if one 'multiple' usage embeddable image has a duplicated filename, using the 'index' template" do
    login_authorised_user
    edition = create(:draft_case_study)
    file = upload_fixture("images/960x640_gif.gif")
    create(:image, edition:, image_data: build(:image_data, file:))

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: [{ image_data_attributes: { file: } }] }

    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name."
  end

  view_test "POST :create shows a validation error if one 'multiple' usage non-embeddable image is too small, using the 'index' template" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "hero" => {
              "label" => "hero",
              "kinds" => %w[hero_mobile],
              "multiple" => true,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition)
    file = upload_fixture("hero_image_mobile_2x.png")

    post :create, params: { edition_id: edition.id, usage: "hero", image_kind: "hero_desktop", images: [{ image_data_attributes: { file: } }] }

    hero_desktop_kind = Whitehall.image_kinds.fetch("hero_desktop")
    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file is too small. Select an image that is at least #{hero_desktop_kind.valid_width} pixels wide and at least #{hero_desktop_kind.valid_height} pixels tall"
  end

  view_test "POST :create shows a validation error if one 'multiple' usage non-embeddable image has a duplicated filename, using the 'index' template" do
    login_authorised_user
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => {
        "images" => {
          "enabled" => "true",
          "usages" => {
            "hero" => {
              "label" => "hero",
              "kinds" => %w[hero_mobile],
              "multiple" => true,
            },
          },
        },
      },
    }))
    edition = create(:draft_standard_edition)
    file = upload_fixture("hero_image_mobile_2x.png")
    create(:image, edition:, image_data: build(:image_data, file:))

    post :create, params: { edition_id: edition.id, usage: "hero", image_kind: "hero_mobile", images: [{ image_data_attributes: { file: } }] }

    assert_template "admin/edition_images/index"
    assert_select ".govuk-error-summary li", "Image data file name is not unique. All your file names must be different. Do not use special characters to create another version of the same file name."
  end

  test "POST :create triggers a job be queued to store image and variants in Asset Manager" do
    login_authorised_user
    edition = create(:draft_case_study)
    file = upload_fixture("images/960x640_jpeg.jpg")
    model_type = ImageData.to_s
    variants = Asset.variants.values

    AssetManagerCreateAssetWorker
      .expects(:perform_async)
      .with(anything, has_entries("assetable_id" => kind_of(Integer), "asset_variant" => any_of(*variants), "assetable_type" => model_type), anything, anything, anything, anything).times(7)

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: [{ image_data_attributes: { file: } }] }
  end

  test "POST :create updates the lead_image association if edition can have a custom lead image" do
    login_authorised_user
    edition = create(:draft_case_study)
    file = upload_fixture("images/960x640_jpeg.jpg")

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: [{ image_data_attributes: { file: } }] }

    assert_equal "960x640_jpeg.jpg", edition.reload.lead_image.filename
  end

  test "POST :create shows success message when all image assets are uploaded" do
    edition = create(:draft_case_study)
    filename = "big-cheese.960x640.jpg"
    Services.asset_manager.stubs(:create_asset).returns({ "id" => "http://asset-manager/assets/some_asset_manager_id", "name" => filename })

    post :create, params: { edition_id: edition.id, usage: "govspeak_embed", image_kind: "default", images: [{ image_data_attributes: { file: upload_fixture(filename, "image/jpeg") } }] }
    AssetManagerCreateAssetWorker.drain

    assert_equal "Images successfully uploaded", flash[:notice]
  end

  test "DELETE :destroy when a lead image is present it deletes the edition_lead_image and sets a new lead image" do
    login_authorised_user
    image1 = build(:image)
    image2 = build(:image)
    edition = create(:draft_case_study, images: [image1, image2])
    create(:edition_lead_image, edition:, image: image1)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id, false).once

    delete :destroy, params: { edition_id: edition.id, id: image1.id }

    assert_equal 1, edition.reload.images.count
    assert_equal image2, edition.lead_image
    assert_redirected_to admin_edition_images_path(edition)
  end

  def login_authorised_user
    user = create(:gds_editor)
    login_as user
  end
end
