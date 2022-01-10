Sentry.init do |config|
    config.dsn = 'https://a08e929c7e0444a198383254f386590c@o1111849.ingest.sentry.io/6141104'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
    # Set tracesSampleRate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production
    config.traces_sample_rate = 1.0
    # or
    config.traces_sampler = lambda do |context|
      true
    end
  end