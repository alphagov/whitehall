module Whitehall::Authority
  module Errors
    class PermissionDenied < StandardError
      attr_reader :action, :subject

      def initialize(action, subject)
        super("Disallowed attempt to perform '#{action}' on '#{subject.inspect}'")
        @action = action
        @subject = subject
      end
    end

    class InvalidAction < StandardError
      attr_reader :action

      def initialize(action)
        super("Disallowed attempt to perform unknown action '#{action}'")
        @action = action
      end
    end
  end
end
