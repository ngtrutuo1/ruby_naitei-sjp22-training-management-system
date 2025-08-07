# frozen_string_literal: true

namespace :daily_reports do
  desc "Deletes all draft daily reports"
  task delete_drafts: :environment do
    DailyReport.draft.find_each do |report|
      report.destroy!
      Rails.logger.info "Đã xóa báo cáo nháp ID: #{report.id}"
    rescue ActiveRecord::RecordNotDestroyed => e
      Rails.logger.error "Xoá ID: #{report.id} thất bại. Error: #{e.message}"
    end

    Rails.logger.info "Hoàn thành việc xóa các báo cáo nháp."
  end
end
