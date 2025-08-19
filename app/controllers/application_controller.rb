class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  helper ComponentGuideHelper
  protect_from_forgery with: :exception, prepend: true

  before_action :set_current_user
  before_action :set_authenticated_user_header
  before_action :check_maintenance_mode

  rescue_from Notifications::Client::BadRequestError, with: :notify_bad_request

private

  def set_current_user
    # current_user is only available within the controller whereas
    # Current.user is available globally for the duration of the
    # user's HTTP request (e.g. within models and service objects)
    Current.user = current_user
  end

  def page_owner_identifier_for(organisation)
    if organisation && organisation.acronym.present?
      organisation.acronym.downcase.parameterize.underscore
    end
  end

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end

  def check_maintenance_mode
    if Flipflop.maintenance_mode?
      render "admin/errors/down_for_maintenance", status: :service_unavailable
    end
  end

  def notify_bad_request(_exception)
    render plain: "Error: One or more recipients not in GOV.UK Notify team (code: 400)", status: :bad_request
  end
end
