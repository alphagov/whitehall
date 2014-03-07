module Frontend
  class StatisticalReleaseAnnouncementProvider
    def self.find_by(filter_params = {})
      release_announcement_hashes = source.find_by(filter_params)
      build_collection(release_announcement_hashes)
    end

  private
    def self.build_collection(release_announcement_hashes)
      Array(release_announcement_hashes).map { | release_announcement_hash | Frontend::StatisticalReleaseAnnouncement.new(release_announcement_hash) }
    end

    def self.source
      Frontend::StatisticalReleaseAnnouncementStubSource
    end
  end

  class StatisticalReleaseAnnouncementStubSource
    RELEASE_ANNOUNCEMENTS = [
      {
        "title" => 'Quarterly bus statistics - Q4 2013',
        "document_type" => 'Statistics',
        "release_date" => Time.zone.parse("2014-03-11 09:30:00"),
        "release_date_text" => nil,
        "organisations" => [ { "name" => "Department of Transport", "slug" => "department-for-transport" } ]
      },
      {
        "title" => 'Incidence of TB in Cattle, Great Britain - Data to December 2013',
        "document_type" => 'National Statistics',
        "release_date" => Time.zone.parse("2014-03-12 00:00:00"),
        "release_date_text" => "12 March 2014",
        "organisations" => [ { "name" => "Department for Environment, Food and Rural Affairs", "slug" => "department-for-environment-food-rural-affairs" } ]
      },
      {
        "title" => 'Building Price and Cost Indices - Quarterly Update March 2014',
        "document_type" => 'National Statistics',
        "release_date" => Time.zone.parse("2014-03-18 09:30:00"),
        "release_date_text" => nil,
        "organisations" => [ { "name" => "Department for Business, Innovation and Skills", "slug" => "department-for-business-innovation-skills" } ]
      },
      {
        "title" => 'UK Armed Forces Monthly Personnel Report - 1 February 2015',
        "document_type" => 'National Statistics',
        "release_date" => Time.zone.parse("2015-03-12 00:00:00"),
        "release_date_text" => "March - April 2015",
        "organisations" => [ { "name" => "Ministry of Defence", "slug" => "ministry-of-defence" } ]
      },
      {
        "title" => 'UK Armed Forces Monthly Personnel Report - 1 June 2015',
        "document_type" => 'National Statistics',
        "release_date" => Time.zone.parse("2015-07-16 00:00:00"),
        "release_date_text" => nil,
        "organisations" => [ { "name" => "Ministry of Defence", "slug" => "ministry-of-defence" } ]
      },
      {
        "title" => 'Hydrocarbon Oils Bulletin - November 2015',
        "document_type" => 'National Statistics',
        "release_date" => Time.zone.parse("2015-12-22 09:30:00"),
        "release_date_text" => "December 2015",
        "organisations" => [ { "name" => "Ministry of Defence", "slug" => "ministry-of-defence" } ]
      }
    ]

    def self.find_by(search_params = {})
      filtered_announcements = RELEASE_ANNOUNCEMENTS.dup
      if search_params[:keywords].present?
        filtered_announcements.select! {|announcement| announcement['title'].downcase.include? search_params[:keywords].downcase }
      end
      if search_params[:from_date].present?
        filtered_announcements.select! {|announcement| announcement['release_date'].to_date >= search_params[:from_date] }
      end
      if search_params[:to_date].present?
        filtered_announcements.select! {|announcement| announcement['release_date'].to_date <= search_params[:to_date] }
      end
      filtered_announcements
    end
  end
end

