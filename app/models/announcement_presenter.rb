require "delegate"

class AnnouncementPresenter
  class Set < SimpleDelegator
    attr_reader :all

    def initialize(announcements, number_to_feature=3)
      @all = announcements.sort_by(&:first_published_at).reverse
      super(@all)
      @number_to_feature = number_to_feature
    end

    def featured
      @all.select { |a| a.lead_image.present? }.take(@number_to_feature)
    end

    def unfeatured
      @all - featured
    end
  end

  def initialize(number_to_feature=3)
    @number_to_feature = number_to_feature
  end

  def today
    return @today if @today
    date = 1.day.ago
    news_today = candidate_news.first_published_since(date)
    speeches_today = candidate_speeches.first_published_since(date)
    @today = Set.new(news_today + speeches_today, @number_to_feature)
  end

  def homepage
    home_news = news.limit(20)
    home_speeches = speeches.limit(20)
    results = home_news + home_speeches
    results.sort_by(&:first_published_at).reverse.take(30)
  end

  def in_last_7_days
    return @in_last_7_days if @in_last_7_days
    this_week = 1.week.ago..1.day.ago
    news_this_week = candidate_news.first_published_during(this_week)
    speeches_this_week = candidate_speeches.first_published_during(this_week)
    @in_last_7_days = Set.new(news_this_week + speeches_this_week, @number_to_feature)
  end

  private

  def news
    NewsArticle.published.by_first_published_at.includes(:document, :edition_relations, :topics)
  end

  def speeches
    Speech.published.by_first_published_at.includes(:document, role_appointment: [:person, :role])
  end

  def candidate_news
    NewsArticle.published.by_first_published_at.includes(:document, :edition_relations, :topics)
  end

  def candidate_speeches
    Speech.published.by_first_published_at.includes(:document, role_appointment: [:person, :role])
  end
end
