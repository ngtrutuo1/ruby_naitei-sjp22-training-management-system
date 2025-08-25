require "rails_helper"

RSpec.describe User, type: :model do
  # Dùng build(:user) để linh hoạt hơn và tận dụng FactoryBot
  subject(:user) { build(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    context "for name" do
      before { user.name = nil }

      it "is not valid when name is nil" do
        expect(user).not_to be_valid
      end

      it "has the correct error message when name is nil" do
        user.valid?
        expect(user.errors[:name]).to include("không thể để trống") 
      end
    end

    context "for email" do
      it "is not valid when nil" do
        user.email = nil
        expect(user).not_to be_valid
      end

      it "is not valid with an invalid email format" do
        user.email = "invalid_email"
        expect(user).not_to be_valid
      end

      it "is not valid with a duplicate email (case insensitive)" do
        create(:user, email: "user@example.com")
        user.email = "USER@EXAMPLE.COM"
        expect(user).not_to be_valid
      end
    end

    context "for birthday" do
      before { user.birthday = nil }

      it "is not valid without a birthday by default" do
        expect(user).not_to be_valid
      end

      it "is valid without a birthday if from_google_oauth" do
        user.from_google_oauth = true
        expect(user).to be_valid
      end
    end

    context "for gender" do
      before { user.gender = nil }

      it "is not valid without a gender by default" do
        expect(user).not_to be_valid
      end

      it "is valid without a gender if from_google_oauth" do
        user.from_google_oauth = true
        expect(user).to be_valid
      end
    end

    it "is not valid when password is too short" do
      user.password = user.password_confirmation = "123" # Giả sử min_length > 3
      expect(user).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:user_courses).dependent(:destroy) }
    it { is_expected.to have_many(:courses).through(:user_courses) }
    it { is_expected.to have_many(:user_subjects).dependent(:destroy) }
    it { is_expected.to have_many(:course_subjects).through(:user_subjects) }
    it { is_expected.to have_many(:subjects).through(:course_subjects) }
    it { is_expected.to have_many(:user_tasks).dependent(:destroy) }
    it { is_expected.to have_many(:tasks).through(:user_tasks) }
    it { is_expected.to have_many(:daily_reports).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:course_supervisors).dependent(:destroy) }
    it { is_expected.to have_many(:supervised_courses).through(:course_supervisors) }
    it { is_expected.to have_one_attached(:image) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:gender) }
    it { is_expected.to define_enum_for(:role) }
  end

  describe "scopes" do
    # Dữ liệu được tạo độc lập trong từng context để tránh "rò rỉ"
    context "ordering and basic filtering" do
      let!(:user_alice) { create(:user, name: "Alice", created_at: 1.day.ago) }
      let!(:user_bob) { create(:user, name: "Bob", created_at: Time.current) }

      it ".recent returns users in descending order of creation" do
        expect(User.where(id: [user_alice.id, user_bob.id]).recent.to_a).to eq([user_bob, user_alice])
      end

      it ".sort_by_name returns users in alphabetical order of name" do
        expect(User.where(id: [user_alice.id, user_bob.id]).sort_by_name.to_a).to eq([user_alice, user_bob])
      end

      context ".filter_by_name('ali')" do
        let(:filtered_users) { User.where(id: [user_alice.id, user_bob.id]).filter_by_name("ali") }
        
        it "includes Alice" do
          expect(filtered_users).to include(user_alice)
        end

        it "does not include Bob" do
          expect(filtered_users).not_to include(user_bob)
        end
      end
    end
    
    context ".filter_by_status" do
      let!(:active_user) { create(:user, activated: true) }
      let!(:inactive_user) { create(:user, activated: false) }

      it "returns only activated users when passed true" do
        expect(User.filter_by_status(true)).to contain_exactly(active_user)
      end

      it "returns only deactivated users when passed false" do
        # Expectation này sẽ pass sau khi bạn sửa scope trong User.rb
        expect(User.filter_by_status(false)).to contain_exactly(inactive_user)
      end
    end
  end

  describe "callbacks" do
    it "downcases email before saving" do
      user.email = "USER@EXAMPLE.COM"
      user.save!
      expect(user.reload.email).to eq("user@example.com")
    end

    context "for activation_digest" do
      it "creates it before creation by default" do
        user.save!
        expect(user.activation_digest).not_to be_nil
      end

      it "skips creation if from_google_oauth is true" do
        user.from_google_oauth = true
        user.save!
        expect(user.activation_digest).to be_nil
      end
    end
  end

  describe "instance methods" do
    # `user` ở đây là `subject`, sẽ được save trong `before` hook
    before { user.save! }

    describe "#authenticated?" do
      it "returns true for the correct token" do
        user.remember
        expect(user.authenticated?(:remember, user.remember_token)).to be true
      end
    end

    describe "#remember" do
      it "sets a remember_digest" do
        user.remember
        expect(user.remember_digest).not_to be_nil
      end
    end

    describe "#forget" do
      it "clears the remember_digest" do
        user.remember
        user.forget
        expect(user.remember_digest).to be_nil
      end
    end

    describe "#create_session" do
      it "sets a remember_digest" do
        user.create_session
        expect(user.remember_digest).not_to be_nil
      end
    end

    describe "#activate" do
      it "sets the activated flag to true" do
        user.activate
        expect(user.activated).to be true
      end
    end
    
    describe "#password_reset_expired?" do
      before { user.create_reset_digest }
      
      it "returns false for a recent reset token" do
        expect(user.password_reset_expired?).to be false
      end

      it "returns true for a token older than 2 hours" do
        user.update_attribute(:reset_sent_at, 3.hours.ago)
        expect(user.password_reset_expired?).to be true
      end
    end
  end

  describe "class methods" do
    it ".new_token returns a non-empty string" do
      expect(User.new_token).to be_a(String).and be_present
    end

    describe ".digest" do
      it "returns a valid BCrypt digest" do
        token = "password"
        digest = User.digest(token)
        expect(BCrypt::Password.new(digest).is_password?(token)).to be true
      end
    end
  end
end
