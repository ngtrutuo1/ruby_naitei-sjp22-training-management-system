require "rails_helper"

RSpec.describe AccountActivationsController, type: :controller do
  let!(:user) { create(:user, activated: false) }
  let(:default_locale) { I18n.default_locale }

  # Trước mỗi test, tạo một activation token hợp lệ cho user
  before do
    user.activation_token = User.new_token
    user.update_attribute(:activation_digest, User.digest(user.activation_token))
  end

  describe "GET #edit" do
    context "with a valid token and correct email" do
      before do
        get :edit, params: { id: user.activation_token, email: user.email, locale: default_locale }
      end

      it "activates the user" do
        expect(user.reload.activated?).to be true
      end

      it "logs the user in" do
        expect(session[:user_id]).to eq(user.id)
      end

      it "sets a success flash message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to the user's profile page" do
        expect(response).to redirect_to(user_path(user, locale: default_locale))
      end
    end

    context "with an invalid token" do
      before do
        get :edit, params: { id: "invalid_token", email: user.email, locale: default_locale }
      end

      it "does not activate the user" do
        expect(user.reload.activated?).to be false
      end

      it "sets a danger flash message" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to the login url" do
        expect(response).to redirect_to(login_url(locale: default_locale))
      end
    end

    context "with a correct token but wrong email" do
      it "redirects to the root url" do
        get :edit, params: { id: user.activation_token, email: "wrong@example.com", locale: default_locale }
        # Giả định controller sẽ redirect về root khi không tìm thấy user qua email
        expect(response).to redirect_to(root_url(locale: default_locale))
      end
    end

    context "for a user who is already activated" do
      before do
        user.activate # Kích hoạt user trước
        get :edit, params: { id: user.activation_token, email: user.email, locale: default_locale }
      end

      it "redirects to the login url" do
        expect(response).to redirect_to(login_url(locale: default_locale))
      end
    end
  end
end
