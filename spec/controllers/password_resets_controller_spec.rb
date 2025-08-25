require "rails_helper"

RSpec.describe PasswordResetsController, type: :controller do
  let!(:user) { create(:user) }
  let(:default_locale) { I18n.default_locale }

  describe "GET #new" do
    it "returns http success" do
      get :new, params: { locale: default_locale }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with a valid email" do
      let(:action) { post :create, params: { password_reset: { email: user.email }, locale: default_locale } }

      it "sends an email" do
        expect { action }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end

      it "sets an info flash message" do
        action
        expect(flash[:info]).to be_present
      end

      it "redirects to the login page" do
        action
        expect(response).to redirect_to(login_url(locale: default_locale))
      end
    end

    context "with an invalid email" do
      before { post :create, params: { password_reset: { email: "invalid@example.com" }, locale: default_locale } }
      
      it "sets an info flash message" do
        expect(flash[:info]).to be_present
      end
      
      it "redirects to the login page" do
        expect(response).to redirect_to(login_url(locale: default_locale))
      end
    end
  end

  describe "GET #edit" do
    before { user.create_reset_digest }

    it "succeeds with a valid token" do
      get :edit, params: { id: user.reset_token, email: user.email, locale: default_locale }
      expect(response).to have_http_status(:success)
    end

    it "redirects with an invalid token" do
      get :edit, params: { id: "invalid_token", email: user.email, locale: default_locale }
      expect(response).to redirect_to(root_url(locale: default_locale))
    end
  end

  describe "PATCH #update" do
    before { user.create_reset_digest }

    context "with valid password" do
      let(:new_password) { "newpassword123" }
      let(:update_params) do
        {
          id: user.reset_token,
          email: user.email,
          user: {
            password:              new_password,
            password_confirmation: new_password
          },
          locale: default_locale
        }
      end

      before do
        patch :update, params: update_params
      end

      it "updates the password" do
        expect(user.reload.authenticate(new_password)).to be_truthy
      end

      it "logs the user in" do
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to the user's profile" do
        expect(response).to redirect_to(user_path(user, locale: default_locale))
      end
    end

    context "with an expired token" do
      it "redirects to the new password reset page" do
        user.update_attribute(:reset_sent_at, 3.hours.ago)
        patch :update, params: { id: user.reset_token, email: user.email, user: { password: "foo", password_confirmation: "bar" }, locale: default_locale }
        expect(response).to redirect_to(new_password_reset_url(locale: default_locale))
      end
    end
  end
end
