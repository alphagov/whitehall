# frozen_string_literal: true

require "test_helper"

class Admin::EditionImages::LeadImageComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "doesn't render if the edition cannot have a custom lead image" do
    edition = build(:edition)
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_empty page.text
  end

  test "renders the correct lead image guidance for case studies" do
    edition = build_stubbed(:draft_case_study)
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    first_para = "Using a lead image is optional. To use a lead image either select the default image for your organisation or upload an image and select it as the lead image."
    second_para = "The lead image appears at the top of the document. The same image cannot be used in the body text."

    assert_selector ".govuk-details__text .govuk-body:nth-child(1)", text: first_para, visible: :hidden
    assert_selector ".govuk-details__text .govuk-body:nth-child(2)", text: second_para, visible: :hidden
  end

  test "renders the correct lead image guidance for other edition types" do
    edition = build_stubbed(:draft_news_article)
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    first_para = "Any image you upload can be selected as the lead image. If you do not select a new lead image, the default image for your organisation will be used."
    second_para = "The lead image appears at the top of the document. The same image cannot be used in the body text."

    assert_selector ".govuk-details__text .govuk-body:nth-child(1)", text: first_para, visible: :hidden
    assert_selector ".govuk-details__text .govuk-body:nth-child(2)", text: second_para, visible: :hidden
  end

  test "renders the correct default fields when a lead image is present" do
    image = build_stubbed(:image, caption: "caption", alt_text: "alt text")
    edition = build_stubbed(:draft_news_article, images: [image], lead_image: image)
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector ".govuk-grid-row .govuk-grid-column-one-third img[alt='Lead image']"
    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(1)", text: "Caption: caption"
    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(2)", text: "Alt text: alt text"
    assert_selector ".app-view-edition-resource__actions a[href='#{edit_admin_edition_image_path(edition, image)}']", text: "Edit details"
    assert_selector ".app-view-edition-resource__actions a[href='#{confirm_destroy_admin_edition_image_path(edition, image)}']", text: "Delete image"
  end

  test "renders placeholder text for caption and alt text when none has been provided" do
    image = build_stubbed(:image, caption: nil, alt_text: nil)
    edition = build_stubbed(:draft_news_article, images: [image], lead_image: image)
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(1)", text: "Caption: None"
    assert_selector ".govuk-grid-row .govuk-grid-column-two-thirds .govuk-body:nth-child(2)", text: "Alt text: None"
  end

  test "renders a processing tag if the lead image if all assets aren't uploaded" do
    image = build_stubbed(:image, image_data: build_stubbed(:image_data_with_no_assets))
    edition = build_stubbed(:draft_news_article, images: [image], lead_image: image)

    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector ".govuk-tag", text: "Processing"
  end

  test "does not render information on lead image if no lead image is present" do
    edition = build_stubbed(:draft_news_article)
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector ".app-c-edition-images-lead-image-component__lead_image", count: 0
    assert_selector ".app-view-edition-resource__actions", count: 0
  end

  test "case studies has the correct fields when image_display_option is 'no_image' and no images have been uploaded" do
    edition = build_stubbed(:draft_case_study, image_display_option: "no_image")
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector "form[action='#{update_image_display_option_admin_edition_path(edition)}']" do
      assert_selector "input[type='hidden'][name='edition[image_display_option]'][value='organisation_image']", visible: :hidden
      assert_selector ".govuk-button", text: "Use default image"
    end
  end

  test "case studies has the correct fields when image_display_option is 'organisation_image' and no images have been uploaded" do
    edition = build_stubbed(:draft_case_study, image_display_option: "organisation_image")
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector "form[action='#{update_image_display_option_admin_edition_path(edition)}']" do
      assert_selector "input[type='hidden'][name='edition[image_display_option]'][value='no_image']", visible: :hidden
      assert_selector ".govuk-button", text: "Remove lead image"
    end
  end

  test "case studies has the correct fields when image_display_option is 'no_image' and images have been uploaded" do
    image = build_stubbed(:image)
    edition = build_stubbed(:draft_case_study, image_display_option: "no_image", images: [image])
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector "form[action='#{update_image_display_option_admin_edition_path(edition)}']" do
      assert_selector "input[type='hidden'][name='edition[image_display_option]'][value='custom_image']", visible: :hidden
      assert_selector ".govuk-button", text: "Show lead image"
    end
  end

  test "case studies has the correct fields when image_display_option is 'custom_image' and images have been uploaded" do
    image = build_stubbed(:image)
    edition = build_stubbed(:draft_case_study, image_display_option: "custom_image", images: [image])
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector "form[action='#{update_image_display_option_admin_edition_path(edition)}']" do
      assert_selector "input[type='hidden'][name='edition[image_display_option]'][value='no_image']", visible: :hidden
      assert_selector ".govuk-button", text: "Hide lead image"
    end
  end

  test "other types of edition do not render image display information" do
    image = build_stubbed(:image)
    edition = build_stubbed(:draft_news_article, image_display_option: "custom_image", images: [image])
    render_inline(Admin::EditionImages::LeadImageComponent.new(edition:))

    assert_selector "form[action='#{update_image_display_option_admin_edition_path(edition)}']", count: 0
    assert_selector "input[type='hidden'][name='edition[image_display_option]']", visible: :hidden, count: 0
  end
end
