module ParamsPreprocessor
  extend ActiveSupport::Concern

  PREPROCESSORS = {
    "telephones" => ParamsPreprocessors::TelephonePreprocessor,
  }.freeze

  def processed_params
    @processed_params ||= begin
      preprocessor = PREPROCESSORS[params[:object_type]]
      if preprocessor
        preprocessor.new(params).processed_params
      else
        params
      end
    end
  end
end
