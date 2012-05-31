class Admin::SpeechesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

  private

  def edition_class
    Speech
  end
end
