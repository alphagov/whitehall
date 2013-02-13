# No matter what happens in config/initializers, there's no reason to use
# anything other than the Fake implementation in test
Rummageable.implementation = Rummageable::Fake.new
