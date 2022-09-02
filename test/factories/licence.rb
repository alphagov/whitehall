FactoryBot.define do
  factory :licence do
    link { "http://link1.com" }
    title { SecureRandom.alphanumeric(10) }
  end

  factory :sector do
    title { SecureRandom.alphanumeric(10) }
  end

  factory :activity do
    title { SecureRandom.alphanumeric(10) }
  end
end
