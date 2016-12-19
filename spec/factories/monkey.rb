FactoryGirl.define do
  factory :monkey do
  end

  factory :hiden_monkey, class: Monkey do
    after(:create) { |monkey| monkey.hide }
  end
end