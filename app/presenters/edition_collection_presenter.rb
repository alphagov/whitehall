class EditionCollectionPresenter
  def initialize(array)
    @array = array
  end

  def method_missing(method, *args, &block)
    wrap_result(@array.__send__(method, *args, &block))
  end

  def respond_to?(method)
    @array.respond_to?(method)
  end

  def each(&block)
    @array.each { |r| yield wrap_result(r) }
  end

  private

  def wrap_result(result)
    if result.is_a?(Enumerable)
      result.map { |r| wrap_result(r) }
    elsif presenter = presenter_for(result)
      presenter.decorate(result)
    else
      result
    end
  end

  def presenter_for(edition)
    case edition
    when Publicationesque
      PublicationesquePresenter
    when Policy
      PolicyPresenter
    when Speech
      SpeechPresenter
    when NewsArticle
      NewsArticlePresenter
    when DetailedGuide
      DetailedGuidePresenter
    when InternationalPriority
      InternationalPriorityPresenter
    when CaseStudy
      CaseStudyPresenter
    when FatalityNotice
      FatalityNoticePresenter
    end
  end
end
