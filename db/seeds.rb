require "faker"

ActiveRecord::Base.transaction do
  # --- Users ---
  5.times do |n|
    User.create!(
      name: "Admin User",
      email: "admin-#{n+1}@example.com",
      birthday: 30.years.ago,
      gender: 1, # male
      role: 2,   # admin
      password: "password",
      password_confirmation: "password",
      activated: true,
      activated_at: Time.zone.now
    )
  end

  10.times do |n|
    User.create!(
      name: Faker::Name.name,
      email: "supervisor-#{n+1}@example.com",
      birthday: Faker::Date.birthday(min_age: 25, max_age: 50),
      gender: rand(0..2),
      role: 1, # supervisor
      password: "password",
      password_confirmation: "password",
      activated: true,
      activated_at: Time.zone.now
    )
  end

  89.times do |n|
    User.create!(
      name: Faker::Name.name,
      email: "trainee-#{n+1}@example.com",
      birthday: Faker::Date.birthday(min_age: 18, max_age: 25),
      gender: rand(0..2),
      role: 0, # trainee
      password: "password",
      password_confirmation: "password",
      activated: true,
      activated_at: Time.zone.now
    )
  end

  supervisors = User.supervisor
  trainees = User.trainee

  # --- Subjects & Categories ---
  20.times do
    Category.create!(name: Faker::Hobby.unique.activity)
  end

  50.times do
    Subject.create!(
      name: Faker::Educator.unique.course_name,
      max_score: 100,
      estimated_time_days: rand(5..15),
      categories: Category.all.sample(rand(1..2))
    )
  end

  # --- Courses & Relationships ---
  20.times do
    start_date = Faker::Date.between(from: 6.months.ago, to: 1.month.from_now)
    course = Course.create!(
      user: supervisors.sample,
      name: "Khóa học #{Faker::ProgrammingLanguage.name} #{start_date.strftime("%m/%Y")}",
      start_date: start_date,
      finish_date: start_date + rand(3..6).months,
      status: rand(0..2)
    )
    course.supervisors = supervisors.sample(rand(1..2))
    course.users = trainees.sample(rand(10..20))
    subjects_for_course = Subject.all.sample(rand(5..10))
    subjects_for_course.each_with_index do |subject, index|
      cs_start = course.start_date + (index * 10).days
      course.course_subjects.create!(
        subject: subject,
        position: index + 1,
        start_date: cs_start,
        finish_date: cs_start + rand(7..14).days
      )
    end
  end

  # --- Tasks ---
  CourseSubject.all.each do |course_subject|
    rand(2..5).times do |i|
      course_subject.tasks.create!(
        name: "Nhiệm vụ #{i+1}: #{Faker::Hacker.verb} the #{Faker::Hacker.noun}"
      )
    end
  end

  # --- User Progress (UserSubjects, UserTasks) ---
  UserCourse.all.each do |user_course|
    user = user_course.user
    course = user_course.course
    course.course_subjects.each do |course_subject|
      user_subject = user_course.user_subjects.create!(
        user: user,
        course_subject: course_subject,
        status: rand(0..5),
        score: rand(0..10)
      )
      course_subject.tasks.each do |task|
        user_subject.user_tasks.create!(
          user: user,
          task: task,
          status: rand(0..1)
        )
      end
    end
  end

  # --- Daily Reports ---
  UserCourse.all.each do |user_course|
    rand(3..10).times do
      user_course.user.daily_reports.create!(
        course: user_course.course,
        content: Faker::Lorem.paragraph(sentence_count: 4),
        is_done: rand(0..1)
      )
    end
  end

  # --- Comments ---
  commentable_items = UserCourse.all.sample(20) + UserSubject.all.sample(30)
  commentable_items.each do |item|
    rand(1..2).times do
      item.comments.create!(
        user: supervisors.sample,
        content: Faker::Lorem.sentence
      )
    end
  end
end
