def should_show_edit_form
  should_show_edit_form_for_email_address_content_block(
    @content_block.document.title,
    @email_address,
  )
end

def should_show_dependent_content
  expect(page).to have_selector("h1", text: "Preview email address")

  @dependent_content.each do |item|
    assert_text item["title"]
    break if item == @dependent_content.last
  end
end

def should_show_rollup_data
  @rollup.keys.each do |k|
    within ".rollup-details__rollup-metric.#{k}" do
      assert_text k.to_s.titleize
      within ".gem-c-glance-metric__figure" do
        assert_text @rollup[k]
      end
    end
  end
end

def should_show_publish_form
  assert_text "Select publish date"
end

def should_be_on_review_step
  assert_text "Review email address"
end

def should_be_on_change_note_step
  assert_text "Do users have to know the content has changed?"
end
