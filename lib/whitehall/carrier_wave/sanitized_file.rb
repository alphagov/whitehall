module CarrierWave
  class SanitizedFile
    def zero_size?
      size.to_i.zero?
    end
  end
end
