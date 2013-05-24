Given /^there is an organisation with no mainstream cateegories defined$/ do
  @the_organisation = create(:ministerial_department)
end

Then /^the public website for the organisation says nothing about mainstream categories$/ do
  visit organisation_path(@the_organisation)

  refute page.has_css?('#mainstream_categories')
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
    select mainstream_category.title, from: "Mainstream category #{idx+1}"
  end
  click_on 'Save'
end

Then /^only the mainstream categories I chose appear on the public website for the organisation, in my specified order$/ do
  visit organisation_path(@the_organisation)

  within '#mainstream_categories' do
    @selected_mainstream_categories.each.with_index do |selected_mainstream_category, idx|
      assert page.has_css?("li.mainstream_category:nth-child(#{idx+1}) h2", text: selected_mainstream_category.title)
    end
    (@all_mainstream_categories - @selected_mainstream_categories).each do |unselected_mainstream_category|
      refute page.has_css?("li.mainstream_category h2", text: unselected_mainstream_category.title)
    end
  end
end
