if Rails.env == 'production'
  Raven.configure do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environments = ['production']
    config.should_capture = Proc.new { |e| Rails.env == 'production' }# unless e.contains_sensitive_info? }
    config.tags = { environment: Rails.env }
  end
end
