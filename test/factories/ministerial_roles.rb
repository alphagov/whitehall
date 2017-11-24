FactoryBot.define do
  factory :ministerial_role, parent: :ministerial_role_without_organisation do
    after :build do |role, evaluator|
      role.organisations = [FactoryBot.build(:ministerial_department)] unless evaluator.organisations.any?
    end
  end

  factory :ministerial_role_without_organisation, class: MinisterialRole do
    name "Parliamentary Under-Secretary of State"
  end
end
