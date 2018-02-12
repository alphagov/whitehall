Given(/^there are some take part pages for the get involved section$/) do
  page_1 = create(:take_part_page, title: 'Wearing a monocole', ordering: 2)
  page_2 = create(:take_part_page, title: 'Riding in a hansom cab', ordering: 3)
  page_3 = create(:take_part_page, title: 'Drinking in a gin palace', ordering: 1)

  @the_take_part_pages_in_order = [page_3, page_1, page_2]
end

When(/^I create a new take part page called "([^"]*)"$/) do |title|
  visit admin_get_involved_path
  click_on 'Take part pages'
  click_on 'Add new take part page'

  fill_in 'Title', with: title
  fill_in 'Summary', with: "A short description of #{title.downcase}"
  fill_in 'Body', with: "A longer description of #{title.downcase}, with some markdown"
  attach_file 'Image', jpg_image
  fill_in 'Image description (alt text)', with: 'A description of the image'

  click_on 'Save'
  @the_new_take_part_page = TakePartPage.last
end

When(/^I reorder the take part pages to highlight my new page$/) do
  visit admin_take_part_pages_path

  @the_take_part_pages_in_order.each.with_index do |take_part_page, idx|
    fill_in take_part_page.title, with: idx + 2
  end
  fill_in @the_new_take_part_page.title, with: 1

  @the_take_part_pages_in_order = [@the_new_take_part_page, *@the_take_part_pages_in_order]

  click_on 'Update order'
end

Then(/^I see the take part pages in my specified order including the new page on the frontend get involved section$/) do
  visit get_involved_path

  take_part_headings = page.all('.take-part-pages article h3').map(&:text)
  @the_take_part_pages_in_order.each.with_index do |take_part_page, idx|
    assert_equal take_part_page.title, take_part_headings[idx]
  end
end

When(/^I remove one of the take part pages because it's not something we want to promote$/) do
  visit admin_get_involved_path
  click_on 'Take part pages'

  click_on @the_take_part_pages_in_order[0].title
  click_on 'Delete'

  click_on @the_take_part_pages_in_order[2].title
  click_on 'Delete'

  @the_removed_pages = [@the_take_part_pages_in_order[0], @the_take_part_pages_in_order[2]]
  @the_take_part_pages_in_order = [@the_take_part_pages_in_order[1]]
end

Then(/^the removed take part page is no longer displayed on the frontend get involved section$/) do
  visit get_involved_path

  within '.take-part-pages' do
    @the_removed_pages.each do |removed_page|
      assert page.has_no_css?('article h3', text: removed_page.title)
    end
  end
end
