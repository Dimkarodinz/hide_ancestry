ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'
require 'factory_girl_rails'
require 'shoulda-matchers'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Add spec/lib folder
Dir[Rails.root.join("spec/lib/*.rb")].each { |f| require f }

ActiveRecord::Migrator.migrations_paths = 'spec/dummy/db/migrate'
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include SharedExamples

  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.order = 'random'
end