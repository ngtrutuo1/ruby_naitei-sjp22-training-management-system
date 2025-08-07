set :output, "log/cron.log"

require File.expand_path("../application", __FILE__)

set :environment, (ENV["RAILS_ENV"] || :development)

case environment
when "development"
  every Settings.cron.delete_drafts_interval_in_minutes.minutes do
    rake "daily_reports:delete_drafts"
  end
when "production"
  every Settings.cron.delete_drafts_interval_in_day.day, at: Settings.cron.delete_time do
    rake "daily_reports:delete_drafts"
  end
end
