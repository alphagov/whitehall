module PublishingApi
  class HowGovernmentWorksEnableReshufflePresenter < HowGovernmentWorksPresenter
    def links
      {
        current_prime_minister: [],
      }
    end

    def details
      {
        reshuffle_in_progress: true,
      }
    end
  end
end
