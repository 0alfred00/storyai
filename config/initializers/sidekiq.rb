# sidekiq setup for heroku

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['rediss://:p634c5951257e13beb0a522ae41be5216f14a769c0013a16872c29e7025456303@ec2-108-128-212-81.eu-west-1.compute.amazonaws.com:32540'] || 'redis://localhost:6379' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['rediss://:p634c5951257e13beb0a522ae41be5216f14a769c0013a16872c29e7025456303@ec2-108-128-212-81.eu-west-1.compute.amazonaws.com:32540'] || 'redis://localhost:6379' }
end
