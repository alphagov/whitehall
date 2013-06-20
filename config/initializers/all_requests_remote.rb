# Rails <3.2.0 will render debug pages in production to requests it considers local.
# Our production stack makes all requests appear local.
# This monkeypatch forces all requests to appear remote.
# 
# The relevant problem code is here (we want it to use "rescue_action_in_public",
# but instead it uses "rescue_action_locally"):
# https://github.com/rails/rails/blob/v3.1.11/actionpack/lib/action_dispatch/middleware/show_exceptions.rb#L68
if Rails.env.production?
  module ActionDispatch
    class Request
      def local?
        false
      end
    end
  end
end
