module HideAncestry
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    config.to_prepare do    
      # Include the extension 
      ActiveRecord::Base.send :include, HasHiddenAncestry
    end
  end
end
