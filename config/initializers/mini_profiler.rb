if Rails.env.development? || Rails.env.production?
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore
  Rack::MiniProfiler.config.position = 'top-right'
  Rack::MiniProfiler.config.enable_hotwire_turbo_drive_support = true
end
