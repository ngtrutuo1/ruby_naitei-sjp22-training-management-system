# db/seeds.rb
require 'faker'

# ==============================================================================
# 1. TẠO DỮ LIỆU ĐỘC LẬP (Users, Categories)
# ==============================================================================

# Tạo Admins
admins = 2.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: 'password',
    role: :admin,
    gender: %i[male female others].sample,
    birthday: Faker::Date.birthday(min_age: 25, max_age: 50),
    activated: true
  )
end

# Tạo Supervisors
supervisors = 5.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: 'password',
    role: :supervisor,
    gender: %i[male female others].sample,
    birthday: Faker::Date.birthday(min_age: 25, max_age: 45),
    activated: true
  )
end

# Tạo Trainees
trainees = 50.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: 'password',
    role: :trainee,
    gender: %i[male female others].sample,
    birthday: Faker::Date.birthday(min_age: 18, max_age: 25),
    activated: true
  )
end

# Tạo Categories
categories = ['Frontend', 'Backend', 'Database', 'DevOps', 'Mobile', 'Soft Skills'].map do |cat_name|
  Category.create!(name: cat_name)
end

# ==============================================================================
# 2. TẠO DỮ LIỆU PHỤ THUỘC CƠ BẢN (Subjects, Courses, Tasks)
# ==============================================================================

# Tạo Subjects và Tasks tương ứng
subjects = 15.times.map do
  subject = Subject.create!(
    name: Faker::Educator.unique.subject,
    max_score: 10,
    estimated_time_days: rand(5..15)
  )

  # Gán category ngẫu nhiên cho subject
  subject.categories << categories.sample(rand(1..2))

  # Tạo các tasks cho subject này
  rand(3..8).times do
    Task.create!(
      name: Faker::Lorem.sentence(word_count: 3),
      estimated_time_minutes: [30, 60, 90, 120, 180, 240].sample,
      taskable: subject
    )
  end
  subject
end

# Tạo Courses
courses = 10.times.map do
  start_date = Faker::Date.between(from: 1.month.ago, to: 1.month.from_now)
  Course.create!(
    name: "Khóa học #{Faker::ProgrammingLanguage.name} tháng #{start_date.month}",
    start_date: start_date,
    finish_date: start_date + rand(30..90).days,
    status: %i[new inprogress finished].sample,
    creator: admins.sample # Một admin sẽ tạo khóa học
  )
end

# ==============================================================================
# 3. TẠO DỮ LIỆU CHO CÁC BẢNG NỐI (JOIN TABLES)
# ==============================================================================

courses.each do |course|
  # Gán supervisors cho khóa học
  course.supervisors << supervisors.sample(rand(1..2))

  # Gán subjects cho khóa học
  course.subjects << subjects.sample(rand(3..6))
end

# Ghi danh trainees vào các khóa học
user_courses = []
trainees.each do |trainee|
  # Mỗi trainee ghi danh vào 1 hoặc 2 khóa học
  courses_to_enroll = courses.sample(rand(1..2))
  courses_to_enroll.each do |course|
    user_courses << UserCourse.create!(
      user: trainee,
      course: course,
      status: %i[new inprogress finished].sample,
      joined_at: course.start_date + rand(0..2).days
    )
  end
end

# ==============================================================================
# 4. TẠO DỮ LIỆU TIẾN ĐỘ CHI TIẾT (LOGIC CỐT LÕI)
# ==============================================================================

# Tạo UserSubjects và UserTasks cho mỗi lượt ghi danh
user_courses.each do |uc|
  trainee = uc.user
  course = uc.course

  # Với mỗi subject trong khóa học của trainee, tạo một bản ghi UserSubject
  course.subjects.each do |subject|
    UserSubject.create!(
      user: trainee,
      course: course,
      subject: subject,
      status: %i[new inprogress finished_early finished_ontime finished_overdue overdue_and_not_finished].sample,
      started_at: uc.joined_at + rand(1..5).days
    )

    # Với mỗi task trong subject đó, tạo một bản ghi UserTask
    subject.tasks.each do |task|
      UserTask.create!(
        user: trainee,
        subject: subject,
        task: task,
        status: %i[not_done done].sample,
        spend_time: task.estimated_time_minutes * rand(0.8..1.5) # Mô phỏng thời gian làm thực tế
      )
    end
  end
end

# ==============================================================================
# 5. TẠO DỮ LIỆU BỔ SUNG (DailyReports, Comments)
# ==============================================================================

# Tạo một vài daily reports
user_courses.sample(30).each do |uc|
  DailyReport.create!(
    user: uc.user,
    course: uc.course,
    report_date: Faker::Date.between(from: uc.joined_at, to: Date.today),
    content: Faker::Lorem.paragraph(sentence_count: 5),
    status: %i[draft sent].sample
  )
end

# Thêm một vài comment vào các khóa học
courses.sample(5).each do |course|
  rand(3..10).times do
    Comment.create!(
      content: Faker::Quote.famous_last_words,
      commentable: course,
      user: (trainees + supervisors + admins).sample
    )
  end
end
