require 'test_helper'

class StatisticsAnnouncementsControllerTest < ActionController::TestCase
  include TextAssertions

  ### Describing #index

  test "#index assign a StatisticsAnnouncementsFilter, populated with get params" do
    organisation = create :organisation
    topic = create :topic

    get :index, keywords: "wombats",
                from_date: "2050-02-02",
                to_date: "2055-01-01",
                organisations: [organisation.slug],
                topics: [topic.slug]

    assert assigns(:filter).is_a? Frontend::StatisticsAnnouncementsFilter
    assert_equal "wombats", assigns(:filter).keywords
    assert_equal Date.new(2050, 2, 2), assigns(:filter).from_date
    assert_equal Date.new(2055, 1, 1), assigns(:filter).to_date
    assert_equal [organisation], assigns(:filter).organisations
    assert_equal [topic], assigns(:filter).topics
  end

  view_test "#index shows correct data other than date for a statistics announcement" do
    Timecop.freeze(Time.local(2014)) do
      organisation = create :organisation, name: "Ministry of beards"
      topic = create :topic, name: "Facial hair trends"

      announcement = create :statistics_announcement, title: "Average beard lengths 2015",
                                                      publication_type_id: PublicationType::NationalStatistics.id,
                                                      organisation: organisation,
                                                      topic: topic

      get :index

      rendered = Nokogiri::HTML::Document.parse(response.body)
      list_item = rendered.css('.document-list li').first

      assert_string_includes "Average beard lengths 2015", list_item.text
      assert_string_includes "national statistics", list_item.text
      assert_has_link organisation.name, organisation_path(organisation), list_item
      assert_has_link topic.name, topic_path(topic), list_item
    end
  end

  view_test "#index shows display_release_date_override if present" do
    Timecop.freeze(Time.local(2014)) do
      announcement = create :statistics_announcement, expected_release_date: Time.zone.parse('2015-01-01'),
                                                      display_release_date_override: "Jan to Feb 2015"

      get :index

      rendered = Nokogiri::HTML::Document.parse(response.body)
      list_item = rendered.css('.document-list li').first

      assert_string_includes "Jan to Feb 2015", list_item.text
    end
  end

  view_test "#index shows expected_release_date if display_release_date_override is not present" do
    Timecop.freeze(Time.local(2014)) do
      announcement = create :statistics_announcement, expected_release_date: Time.zone.parse('2015-07-08 09:30'),
                                                      display_release_date_override: nil

      get :index

      rendered = Nokogiri::HTML::Document.parse(response.body)
      list_item = rendered.css('.document-list li').first

      assert_string_includes "July 08, 2015 09:30", list_item.text
    end
  end

  view_test "#index displays no results text when there aren't any results" do
    get :index
    rendered = Nokogiri::HTML::Document.parse(response.body)
    assert_string_includes "There are no matching announcements", rendered.text
  end

  test "#index sets cache control max-age to Whitehall::default_cache_max_age if no release announcements are due to expire within that window" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    create :statistics_announcement, expected_release_date: 1.day.from_now
    get :index
    assert_cache_control("max-age=#{15.minutes}")
  end

  test "#index sets cache control max-age to expire when the next announcement expires" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    create :statistics_announcement, expected_release_date: 2.minutes.from_now
    create :statistics_announcement, expected_release_date: 10.minutes.from_now
    create :statistics_announcement, expected_release_date: 1.minute.ago
    get :index
    assert_cache_control("max-age=#{2.minutes}")
  end

  view_test "#index responds to xhr requests, rendering only the filter_results partial in response" do
    xhr :get, :index

    assert_response :success
    assert_template layout: nil, partial: 'statistics_announcements/_filter_results'
  end


  ### Describing #show

  test "#show assigns @announcement as a Frontend::StatisticsAnnouncement inflated from the publisher model" do
    announcement = create :statistics_announcement
    get :show, id: announcement.slug
    assert assigns(:announcement).is_a?(Frontend::StatisticsAnnouncement)
    assert_equal announcement.slug, assigns(:announcement).slug
  end

  test "#show responds with 404 if announcement not found" do
    get :show, id: "not-a-slug"
    assert_equal 404, response.status
  end

  test "#show redirects to publication show page if linked publication is already published" do
    statistics = create :published_statistics
    announcement = create :statistics_announcement, publication: statistics

    get :show, id: announcement.slug

    assert response.redirect?
    assert_equal publication_url(statistics), response.redirect_url
  end

  test "#show sets cache control max-age to Whitehall::default_cache_max_age if neither announcement's expected release date and it's linked document's publication date are within the window" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    announcement = create :statistics_announcement,
                          expected_release_date: 1.day.from_now,
                          publication: create(:scheduled_publication, :statistics,
                                              scheduled_publication: 1.day.from_now)
    get :show, id: announcement.slug
    assert_cache_control("max-age=#{15.minutes}")
  end

  test "#show sets cache control max-age to the statistics_announcement's expected_release_date if that is before it's publication's scheduled publication date" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    announcement = create :statistics_announcement,
                          expected_release_date: 2.minutes.from_now,
                          publication: create(:scheduled_publication, :statistics,
                                              scheduled_publication: 3.minutes.from_now)
    get :show, id: announcement.slug
    assert_cache_control("max-age=#{2.minutes}")
  end

  test "#show sets cache control max-age to the statistics_announcement's linked publication's scheduled publication date if that is before the expected_release_date" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    announcement = create :statistics_announcement,
                          expected_release_date: 5.minutes.from_now,
                          publication: create(:scheduled_publication, :statistics,
                                              scheduled_publication: 4.minutes.from_now)
    get :show, id: announcement.slug
    assert_cache_control("max-age=#{4.minutes}")
  end
end
