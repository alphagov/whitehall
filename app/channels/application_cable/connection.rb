# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    before_command :set_authenticated_user_header

    def connect
      self.current_user = find_verified_user
    end

  private

    def find_verified_user
      Current.user = current_user
    end

    def set_authenticated_user_header
      if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
        GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
      end
    end
  end
end
