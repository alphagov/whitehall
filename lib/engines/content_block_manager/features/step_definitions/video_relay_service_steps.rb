Given("I indicate that the video relay service info should be displayed") do
  check label_for("show")
end

Given("I provide custom video relay service info where available") do
  within(".app-c-content-block-manager-video-relay-service-component") do
    fill_in(label_for("prefix"), with: "**Custom** prefix: 12345 then")
    should_be_able_to_preview_the_govspeak_enabled_field
    fill_in(label_for("telephone_number"), with: "01777 123 1234")
  end
end

When("I should see that the video relay service info is to be shown") do
  within(".gem-c-summary-card[title='Video Relay Service']") do
    expect(page).to have_css("dt", text: "Show")
    expect(page).to have_css("dt", text: "true")
  end
end

When("I should see that the custom video relay info has been recorded") do
  within(".gem-c-summary-card[title='Video Relay Service']") do
    expect(page).to have_content("01777 123 1234")
    expect(page).to have_content("**Custom** prefix: 12345 then")
  end
end

def label_for(field_name)
  I18n.t("content_block_edition.details.labels.telephones.video_relay_service.#{field_name}")
end

def should_be_able_to_preview_the_govspeak_enabled_field
  click_button("Preview")
  preliminary_preview_text = page.find(".app-c-govspeak-editor__preview p").text

  assert_equal(
    "Generating preview, please wait.",
    preliminary_preview_text,
  )
end
