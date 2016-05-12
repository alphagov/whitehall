module PublishingApiPresenters::ApplicabilityHelper
private

  def nation_to_sym(nation)
    nation.tr(' ', '_').downcase.to_sym
  end

  def universally_applicable
    all_nations = %w(England Northern\ Ireland Scotland Wales)
    all_nations.reduce({}) { |hash, nation|
      key = nation_to_sym(nation)
      hash[key] = {
        label: nation,
        applicable: true
      }
      hash
    }
  end

  def national_applicability
    nations = universally_applicable

    inapplicabilities = item.nation_inapplicabilities
    nations = inapplicabilities.reduce(nations) { |hash, inapplicability|
      key = nation_to_sym(inapplicability.nation.name)
      hash[key][:applicable] = false
      hash[key][:alternative_url] = inapplicability.alternative_url if inapplicability.alternative_url
      hash
    }

    nations
  end
end
