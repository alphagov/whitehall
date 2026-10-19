module Presenters::PublishingApi::NationApplicabilityHelper
private

  def cast_nation_applicability(value)
    return [] unless value.is_a?(Hash)

    (value["selected"] || []).map do |nation|
      { "nation" => nation, "alternative_url" => value.dig(nation, "alternative_url") }.compact_blank
    end
  end
end
