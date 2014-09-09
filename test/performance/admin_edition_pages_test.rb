require 'benchmark_helper'

class AdminEditionPagesTest < ActionDispatch::PerformanceTest
  setup do
    login_as editor
  end

  teardown do
    logout
  end

  test 'new case study page' do
    get '/government/admin/case-studies/new'
  end

  test 'edit case study page' do
    consultation = CaseStudy.draft.last
    get "/government/admin/case-studies/#{consultation.id}/edit"
  end

  test 'new consultation page' do
    get '/government/admin/consultations/new'
  end

  test 'edit consultation page' do
    consultation = Consultation.draft.last
    get "/government/admin/consultations/#{consultation.id}/edit"
  end

  test 'new detailed guide page' do
    get '/government/admin/detailed-guides/new'
  end

  test 'edit detailed guide page' do
    guide = DetailedGuide.draft.last
    get "/government/admin/detailed-guides/#{guide.id}/edit"
  end

  test 'new news page' do
    get '/government/admin/news/new'
  end

  test 'edit news page' do
    news = NewsArticle.draft.last
    get "/government/admin/news/#{news.id}/edit"
  end

  test 'new policy page' do
    get '/government/admin/policies/new'
  end

  test 'edit policy page' do
    policy = Policy.draft.last
    get "/government/admin/policies/#{policy.id}/edit"
  end

  test 'new publication page' do
    get '/government/admin/publications/new'
  end

  test 'edit publication page' do
    publication = Publication.draft.last
    get "/government/admin/publications/#{publication.id}/edit"
  end

  test 'new speech page' do
    get '/government/admin/speeches/new'
  end

  test 'edit speech page' do
    speech = Speech.draft.last
    get "/government/admin/speeches/#{speech.id}/edit"
  end

  test 'new supporting page page' do
    get '/government/admin/supporting-pages/new'
  end

  test 'edit supporting page page' do
    supporting_page = SupportingPage.draft.last
    get "/government/admin/supporting-pages/#{supporting_page.id}/edit"
  end

  test 'new worldwide priority page' do
    get '/government/admin/priority/new'
  end

  test 'edit worldwide priority page' do
    worldwide_priority = WorldwidePriority.draft.last
    get "/government/admin/priority/#{worldwide_priority.id}/edit"
  end

  test 'new world location news page' do
    get '/government/admin/world-location-news/new'
  end

  test 'edit world location news page' do
    world_location_news = WorldLocationNewsArticle.draft.last
    get "/government/admin/world-location-news/#{world_location_news.id}/edit"
  end
end
