module ContentObjectStore
  module ChangeDispatcher
    class Now
      def verb
        "changed and published"
      end
    end

    class Schedule
      def verb
        "scheduled"
      end
    end
  end
end
