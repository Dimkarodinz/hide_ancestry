Shoulda::Matchers.configure do |shoulda|
  shoulda.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end