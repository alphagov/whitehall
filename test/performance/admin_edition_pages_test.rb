require 'benchmark_helper'

class AdminEditionPagesTest < ActionDispatch::PerformanceTest
  setup do
    login_as editor
  end

  teardown do
    logout
  end

  test 'new publication page' do
    get '/government/admin/publications/new'
  end

  test 'edit publication page' do
    publication = Publication.draft.last
    get "/government/admin/publications/#{publication.id}/edit"
  end

  test 'new news page' do
    get '/government/admin/news/new'
  end

  test 'edit news page' do
    news = NewsArticle.draft.last
    get "/government/admin/news/#{news.id}/edit"
  end

  test 'new detailed guide page' do
    get '/government/admin/detailed-guides/new'
  end

  test 'edit detailed guide page' do
    guide = DetailedGuide.draft.last
    get "/government/admin/detailed-guides/#{guide.id}/edit"
  end

  test 'new speech page' do
    get '/government/admin/speeches/new'
  end

  test 'edit speech page' do
    speech = Speech.draft.last
    get "/government/admin/speeches/#{speech.id}/edit"
  end
end
