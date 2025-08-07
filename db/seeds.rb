def associate_course_relations(course, supervisors, trainees)
  course.supervisors = supervisors.sample(rand(1..2))
  course.users = trainees.sample(rand(10..20))

  subjects_for_course = Subject.all.sample(rand(5..10))
  subjects_for_course.each_with_index do |subject, index|
    cs_start = course.start_date + (index * 10).days
    finish_offset = rand(7..14)
    cs_finish = [cs_start + finish_offset.days, course.finish_date].min
    cs_start = cs_finish if cs_start > cs_finish

    course.course_subjects.create!(
      subject: subject,
      position: index + 1,
      start_date: cs_start,
      finish_date: cs_finish
    )
  end
end

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
  5.times do
    Category.create!(name: Faker::Hobby.unique.activity)
  end

  50.times do
    Subject.create!(
      name: Faker::Educator.unique.course_name,
      max_score: 10,
      estimated_time_days: rand(5..15),
      categories: Category.all.sample(rand(1..5))
    )
  end

  puts "  -> Creating 8 FINISHED courses..."
  8.times do
    finish_date = Faker::Date.between(from: 6.months.ago, to: 8.days.ago)
    start_date = finish_date - rand(2..4).months
    course = Course.create!(
      user: supervisors.sample,
      name: "#{Faker::ProgrammingLanguage.name} #{start_date.strftime("%m/%Y")}",
      start_date: start_date,
      finish_date: finish_date,
      status: 2
    )
    associate_course_relations(course, supervisors, trainees)
  end

  puts "  -> Creating 10 IN-PROGRESS courses..."
  10.times do
    start_date = Faker::Date.between(from: 3.months.ago, to: 1.day.ago)
    finish_date = Faker::Date.between(from: Time.zone.today - 6.days, to: 3.months.from_now)
    course = Course.create!(
      user: supervisors.sample,
      name: "#{Faker::ProgrammingLanguage.name} #{start_date.strftime("%m/%Y")}",
      start_date: start_date,
      finish_date: finish_date,
      status: 1
    )
    associate_course_relations(course, supervisors, trainees)
  end

  puts "  -> Creating 12 PENDING courses..."
  12.times do
    start_date = Faker::Date.between(from: 1.day.from_now, to: 2.months.from_now)
    finish_date = start_date + rand(2..4).months
    course = Course.create!(
      user: supervisors.sample,
      name: "#{Faker::ProgrammingLanguage.name} #{start_date.strftime("%m/%Y")}",
      start_date: start_date,
      finish_date: finish_date,
      status: 0
    )
    associate_course_relations(course, supervisors, trainees)
  end


  # --- Tasks ---
  CourseSubject.all.each do |course_subject|
    rand(2..5).times do |i|
      course_subject.tasks.create!(
        name: "#{Faker::Hacker.verb}, #{Faker::Hacker.noun}"
      )
    end
  end

  # --- User_Courses ---
  UserCourse.all.each do |user_course|
    user = user_course.user
    course = user_course.course

    course.course_subjects.each do |course_subject|
      user_subject_status = 0
      user_score = nil

      if course.finished?
        user_subject_status = 2
        user_score = rand(6..10)
      elsif course.in_progress?
        user_subject_status = rand(0..2)
        user_score = user_subject_status == 2 ? rand(5..10) : rand(0..5)
      else 
        user_subject_status = 0
        user_score = nil
      end

      user_subject = user_course.user_subjects.create!(
        user: user,
        course_subject: course_subject,
        status: user_subject_status,
        score: user_score
      )
      
      if user_subject.status != 0
        course_subject.tasks.each do |task|
          task_status = [2, 3, 4].include?(user_subject.status) ? 1 : 0
          user_subject.user_tasks.create!(
            user: user,
            task: task,
            status: task_status
          )
        end
      end
    end
  end

  # --- Daily Reports ---
 UserCourse.all.each do |user_course|
    user = user_course.user
    course = user_course.course
    start_day = course.start_date
    end_day = [Time.zone.today, course.finish_date].min 

    next if start_day > end_day

    (start_day..end_day).each do |date|
      next if rand > 0.8
      report_status = rand > 0.15 ? 1 : 0

      DailyReport.create!(
        user: user,
        course: course,
        content: Faker::Lorem.paragraph(sentence_count: rand(3..6)),
        status: report_status,
        created_at: date.at_beginning_of_day, # Gán ngày tạo là ngày đang lặp
        updated_at: date.at_beginning_of_day
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
