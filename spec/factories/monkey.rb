FactoryGirl.define do
  factory :monkey do
  end

  factory :hidden_monkey, class: Monkey do
    after(:create) { |monkey| monkey.hide }
  end
end