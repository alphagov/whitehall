require 'test_helper'

class StatisticsAnnouncementsControllerTest < ActionController::TestCase
  include TextAssertions

  test "#index assign a StatisticsAnnouncementsFilter, populated with get params" do
    organisation = create :organisation
    taxon = build(:taxon_hash, content_id: 'id-123', title: 'Taxon 123')

    redis_cache_has_taxons([taxon])

    get :index, params: {
                  keywords: "wombats",
                  from_date: "2050-02-02",
                  to_date: "2055-01-01",
                  organisations: [organisation.slug],
                  topics: ['id-123']
                }

    assert assigns(:filter).is_a? Frontend::StatisticsAnnouncementsFilter
    assert_equal "wombats", assigns(:filter).keywords
    assert_equal Date.new(2050, 2, 2), assigns(:filter).from_date
    assert_equal Date.new(2055, 1, 1), assigns(:filter).to_date
    assert_equal [organisation], assigns(:filter).organisations
    assert_equal 'Taxon 123', assigns(:filter).topics.first.name
  end

  view_test "#index shows correct data for a statistics announcement" do
    Timecop.freeze(Time.local(2014)) do
      organisation = create :organisation, name: "Ministry of beards"
      taxon = build(:taxon_hash, content_id: 'id-123', title: 'Taxon 123')

      redis_cache_has_taxons([taxon])

      past_announcement_date = build(
        :statistics_announcement_date,
        release_date: Time.zone.parse("2050-01-01 09:30:00"),
        precision: StatisticsAnnouncementDate::PRECISION[:exact],
        confirmed: true
      )

      future_announcement_date = build(
        :statistics_announcement_date,
        release_date: Time.zone.parse("2013-01-01 09:30:00"),
        precision: StatisticsAnnouncementDate::PRECISION[:exact],
        confirmed: true
      )

      create(:statistics_announcement,
             title: "Average beard lengths 2050",
             publication_type_id: PublicationType::NationalStatistics.id,
             organisation_ids: [organisation.id],
             current_release_date: past_announcement_date)

      create(:statistics_announcement,
             title: "Average moustache lengths 2013",
             publication_type_id: PublicationType::NationalStatistics.id,
             organisation_ids: [organisation.id],
             current_release_date: future_announcement_date)

      get :index

      assert_equal 1, assigns(:filter).results.size

      rendered = Nokogiri::HTML::Document.parse(response.body)
      list_item = rendered.css('.document-list li').first

      assert_string_includes "Average beard lengths 2050", list_item.text
      assert_string_includes "National Statistics", list_item.text
      assert_string_includes "1 January 2050 9:30am", list_item.text
      assert_has_link organisation.name, organisation_path(organisation), list_item
    end
  end

  view_test "#index displays no results text when there aren't any results" do
    taxon = build(:taxon_hash, content_id: 'id-123', title: 'Taxon 123')

    redis_cache_has_taxons([taxon])

    get :index
    rendered = Nokogiri::HTML::Document.parse(response.body)
    assert_string_includes "There are no matching announcements", rendered.text
  end

  test "#index sets cache control max-age to Whitehall::default_cache_max_age if no release announcements are due to expire within that window" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    create :statistics_announcement, current_release_date: build(:statistics_announcement_date, release_date: 1.day.from_now)
    get :index
    assert_cache_control("max-age=#{15.minutes}")
  end

  test "#index sets cache control max-age to expire when the next announcement expires" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    create :statistics_announcement, current_release_date: build(:statistics_announcement_date, release_date: 2.minutes.from_now)
    create :statistics_announcement, current_release_date: build(:statistics_announcement_date, release_date: 10.minutes.from_now)
    create :statistics_announcement, current_release_date: build(:statistics_announcement_date, release_date: 1.minute.ago)
    get :index
    assert_cache_control("max-age=#{2.minutes}")
  end

  view_test "#index responds to xhr requests, rendering only the filter_results partial in response" do
    get :index, xhr: true

    assert_response :success
    assert_template layout: nil, partial: 'statistics_announcements/_filter_results'
  end
end
