# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = {
    url: 'redis://127.0.0.1:6379',
    namespace: ENV.fetch('SIDEKIQ_NAMESPACE', 'offers')
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: 'redis://127.0.0.1:6379',
    namespace: ENV.fetch('SIDEKIQ_NAMESPACE', 'offers')
  }
end
