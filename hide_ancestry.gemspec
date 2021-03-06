$:.push File.expand_path("../lib", __FILE__)

require "hide_ancestry/version"

Gem::Specification.new do |s|
  s.name        = "hide_ancestry"
  s.version     = HideAncestry::VERSION
  s.authors     = ["Dimkarodinz"]
  s.email       = ["dimkarodin@gmail.com"]
  s.homepage    = "https://github.com/Dimkarodinz/hide_ancestry"
  s.summary     = "Hide and restore ancestry gem nodes"
  s.description = "Hide and restore nodes of ancestry gem"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", '~> 4.2', '>= 4.2.5'
  s.add_dependency "ancestry", '~> 2.2', '>= 2.2.2'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "shoulda-matchers"

  s.required_ruby_version = '>= 2.3.0'
end
