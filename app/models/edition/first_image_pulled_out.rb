module Edition::FirstImagePulledOut
  extend ActiveSupport::Concern

  included do
    validates :body, format: {
      without: /^!!1[^\w]/,
      message: "cannot have a reference to the first image in the text"
    }
  end

  def image_disallowed_in_body_text?(i)
    i == 1
  end
end
