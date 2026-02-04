module CarrierWave
  class SanitizedFile
    def zero_size?
      size.to_i.zero?
    end

    def bitmap?
      content_type !~ /svg/
    end
  end
end
