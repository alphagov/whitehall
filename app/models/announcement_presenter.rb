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
      @all.select { |a| a.images.any? }.take(@number_to_feature)
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

  def in_last_7_days
    return @in_last_7_days if @in_last_7_days
    this_week = 1.week.ago..1.day.ago
    news_this_week = candidate_news.first_published_during(this_week)
    speeches_this_week = candidate_speeches.first_published_during(this_week)
    @in_last_7_days = Set.new(news_this_week + speeches_this_week, @number_to_feature)
  end

  private

  def candidate_news
    NewsArticle.published.not_featured.by_first_published_at.includes(:document_identity, :document_relations, :policy_topics)
  end

  def candidate_speeches
    Speech.published.by_first_published_at.includes(:document_identity, role_appointment: [:person, :role])
  end
end