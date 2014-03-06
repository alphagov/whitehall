Given(/^There are some release announcements in rummager$/) do
  @release_announcements_in_rummager = [
    {
      "title" => 'Womble to Wombat population ratios',
      "document_type" => 'Statistics',
      "release_date" => Time.zone.parse("2050-02-15 12:45:00"),
      "release_date_text" => nil,
      "organisations" => [ { "name" => "Wombat population regulation authority", "slug" => "wombat-population-regulation-authority" } ]
    },
    {
      "title" => '2055 beard lengths',
      "document_type" => 'National Statistics',
      "release_date" => Time.zone.parse("2050-05-01 12:00:00"),
      "release_date_text" => 'May - June 2055',
      "organisations" => [ { "name" => "Ministry of beards", "slug" => "ministry-of-breards" } ]
    },
    {
      "title" => 'Wombat population in Wimbledon Common 2063',
      "document_type" => 'Statistics',
      "release_date" => Time.zone.parse("2063-02-15 12:45:00"),
      "release_date_text" => nil,
      "organisations" => [ { "name" => "Wombat population regulation authority", "slug" => "wombat-population-regulation-authority" } ]
    }
  ]
  @mock_rummager_api = mock
  @mock_rummager_api.stubs(:release_announcements).with({}).returns(@release_announcements_in_rummager)
  Frontend::ReleaseAnnouncementProvider.stubs(:rummager_api).returns(@mock_rummager_api)
end

When(/^I visit the release announcements page$/) do
  visit release_announcements_path
end

When(/^I filter the release announcements by keyword, from_date and to_date$/) do
  @mock_rummager_api.stubs(:release_announcements)
                      .with({ keywords: "Wombat",
                              from_date: Date.new(2050, 1, 1),
                              to_date: Date.new(2051, 1, 1) })
                      .returns([@release_announcements_in_rummager.first])

  within '.filter-block' do
    fill_in "Contains", with: "Wombat"
    fill_in "Published after", with: "2050-01-01"
    fill_in "Published before", with: "2051-01-01"
    click_on "Refresh results"
  end
end

Then(/^I should all the release announcements$/) do
  @release_announcements_in_rummager.each do | release_announcement_hash |
    assert page.has_content? release_announcement_hash["title"]
    assert page.has_content? release_announcement_hash["document_type"]
    if release_announcement_hash["release_date_text"].nil?
      assert page.has_content? release_announcement_hash["release_date"].to_s(:long)
    else
      assert page.has_content? release_announcement_hash["release_date_text"]
    end
    release_announcement_hash["organisations"].each do | org_data |
      assert page.has_content? org_data['name']
    end
  end
end

Then(/^I should only see release announcements for those filters$/) do
  assert page.has_content? "Womble to Wombat population ratios"
  assert_equal 1, page.all(".document-list .document-row").length
end

