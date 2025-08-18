namespace :user_subjects do
  desc "Sync user_subject statuses with course_subject schedule"
  task sync_statuses: :environment do
    UserSubjectStatusSync.run
  end
end
