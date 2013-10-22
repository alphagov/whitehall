Given /^there is an organisation with no mainstream categories defined$/ do
  @the_organisation = create(:ministerial_department)
end

Then /^the public page for the organisation says nothing about mainstream categories$/ do
  visit organisation_path(@the_organisation)

  assert page.has_no_css?('#mainstream_categories')
end

Then /^the admin page for the organisation says it has no mainstream categories$/ do
  visit admin_organisation_path(@the_organisation)

  assert page.has_css?('.mainstream_categories td', text: 'None')
end

Given /^there are some mainstream categories$/ do
  @all_mainstream_categories = [
    create(:mainstream_category, title: 'Something important'),
    create(:mainstream_category, title: 'Something frivolous'),
    create(:mainstream_category, title: 'Something momentous'),
    create(:mainstream_category, title: 'Something disgusting'),
    create(:mainstream_category, title: 'Something horrifying')
  ]
end

When /^I add a few of those mainstream categories in a specific order to the organisation$/ do
  visit edit_admin_organisation_path(@the_organisation)
  @selected_mainstream_categories = @all_mainstream_categories.shuffle.take(3)
  @selected_mainstream_categories.each.with_index do |mainstream_category, idx|
    select mainstream_category.title, from: "organisation_mainstream_category_ids_#{idx+1}"
  end
  click_on 'Save'
end

Then /^only the mainstream categories I chose appear on the public page for the organisation, in my specified order$/ do
  visit organisation_path(@the_organisation)

  within '#mainstream_categories' do
    @selected_mainstream_categories.each.with_index do |selected_mainstream_category, idx|
      assert page.has_css?("li.mainstream_category:nth-child(#{idx+1}) h2", text: selected_mainstream_category.title)
    end
    (@all_mainstream_categories - @selected_mainstream_categories).each do |unselected_mainstream_category|
      assert page.has_no_css?("li.mainstream_category h2", text: unselected_mainstream_category.title)
    end
  end
end

Then /^they also appear on the admin page, in my specified order$/ do
  visit admin_organisation_path(@the_organisation)

  assert page.has_css?('.mainstream_categories td', text: @selected_mainstream_categories.map {|mc| "#{mc.title} (#{mc.parent_title})" }.to_sentence)
end
