Given(/^There are some release announcements in rummager$/) do
  @release_announcements_in_rummager = [
    {
      "title" => '2055 beard lengths',
      "document_type" => 'National Statistics',
      "release_date" => Time.zone.parse("2055-05-01 12:00:00"),
      "release_date_text" => 'May - June 2055',
      "organisations" => [ { "name" => "Ministry of beards", "slug" => "ministry-of-breards" } ]
    },
    {
      "title" => 'Womble population in Wimbledon Common 2063',
      "document_type" => 'Statistics',
      "release_date" => Time.zone.parse("2063-02-15 12:45:00"),
      "release_date_text" => nil,
      "organisations" => [ { "name" => "Wombat population regulation authority", "slug" => "wombat-population-regulation-authority" } ]
    }
  ]
  Frontend::ReleaseAnnouncementProvider.stubs(:rummager_api).returns(mock(release_announcements: @release_announcements_in_rummager))
end

When(/^I visit the release announcements page$/) do
  visit release_announcements_path
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
