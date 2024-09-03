module ContentObjectStore
  class ResultMonad < Data.define(:success, :message, :object)
    def success?
      success == true
    end

    def failure?
      !success?
    end
  end
end
