Given(/^there are some take part pages for the get involved section$/) do
  @page1 = create(:take_part_page, title: "Wearing a monocole", ordering: 2)
  @page2 = create(:take_part_page, title: "Riding in a hansom cab", ordering: 3)
  @page3 = create(:take_part_page, title: "Drinking in a gin palace", ordering: 1)

  @the_take_part_pages_in_order = [@page3, @page1, @page2]
end

When(/^I create a new take part page called "([^"]*)"$/) do |title|
  visit admin_get_involved_path
  click_on "Take part pages"
  click_on "Add new take part page"

  fill_in "Title", with: title
  fill_in "Summary", with: "A short description of #{title.downcase}"
  fill_in "Body", with: "A longer description of #{title.downcase}, with some markdown"
  attach_file "Upload image", jpg_image
  fill_in "Image description (alt text)", with: "A description of the image"

  click_on "Save"
  @the_new_take_part_page = TakePartPage.last
end

When(/^I reorder the take part pages to highlight my new page$/) do
  visit update_order_admin_take_part_pages_path

  @the_take_part_pages_in_order.each.with_index do |take_part_page, idx|
    fill_in take_part_page.title, with: idx + 2
  end

  fill_in @the_new_take_part_page.title, with: 1

  @the_take_part_pages_in_order = [@the_new_take_part_page, *@the_take_part_pages_in_order]

  click_on "Update order"
end

Then(/^I see the take part pages in my specified order including the new page on the admin view$/) do
  visit admin_get_involved_path
  click_on "Take part pages"

  # Note that the selector is for the non-JS version of the page
  take_part_pages = page.all(".gem-c-table .govuk-table__row td:first").map(&:text)

  @the_take_part_pages_in_order.each.with_index do |take_part_page, idx|
    expect(take_part_page.title).to eq(take_part_pages[idx])
  end
end

When(/^I remove one of the take part pages because it's not something we want to promote$/) do
  visit admin_get_involved_path
  click_on "Take part pages"

  find(".gem-c-table .govuk-table__row:nth-child(2)").find("a", text: "Delete").click
  find("button", text: "Delete").click

  find(".gem-c-table .govuk-table__row:nth-child(2)").find("a", text: "Delete").click
  find("button", text: "Delete").click

  @the_removed_pages = [@the_take_part_pages_in_order[0], @the_take_part_pages_in_order[2]]
  @the_take_part_pages_in_order = [@the_take_part_pages_in_order[1]]
end

Then(/^the relevant take part pages are removed$/) do
  visit admin_get_involved_path
  click_on "Take part pages"

  expect(page).to_not have_content(@page1.title)
  expect(page).to_not have_content(@page2.title)
  expect(page).to have_content(@page3.title)
end
