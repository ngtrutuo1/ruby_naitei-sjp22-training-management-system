set :output, "log/cron.log"

require File.expand_path("../application", __FILE__)

set :environment, (ENV["RAILS_ENV"] || :development)

case environment
when "development"
  every Settings.cron.delete_drafts_interval_in_minutes.minutes do
    rake "daily_reports:delete_drafts"
  end
  every 1.day, at: "12:10 am" do
    rake "user_subjects:sync_statuses"
  end
when "production"
  every Settings.cron.delete_drafts_interval_in_day.day, at: Settings.cron.delete_time do
    rake "daily_reports:delete_drafts"
  end
  every 1.day, at: Settings.cron.delete_time do
    rake "user_subjects:sync_statuses"
  end
end
