class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  layout 'website'

  private

  def authenticate!
    unless current_user
      redirect_away login_path, alert: "You're not authorised to view this page"
    end
  end

  def login(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def logout
    @current_user = nil
    reset_session
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def load_published_documents_in_scope(&block)
    @policies = yield(Policy.published)
    @publications = yield(Publication.published)
    @news_articles = yield(NewsArticle.published)
    @consultations = yield(Consultation.published)
  end

  def skip_slimmer
    response.headers[Slimmer::SKIP_HEADER] = "true"
  end
end