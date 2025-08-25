require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let(:default_locale) { I18n.default_locale }

  describe "GET #new" do
    context "when user is not logged in" do
      before { get :new, params: { locale: default_locale } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the new template" do
        expect(response).to render_template(:new)
      end
    end

    context "when user is already logged in" do
      let(:user) { create(:user) }
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
        get :new, params: { locale: default_locale }
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path(locale: default_locale))
      end
    end
  end

  describe "POST #create" do
    let!(:activated_user) { create(:user, password: "password123", activated: true) }
    let!(:unactivated_user) { create(:user, password: "password123", activated: false) }

    context "with valid credentials and activated account" do
      before { post :create, params: { session: { email: activated_user.email, password: "password123" }, locale: default_locale } }

      it "sets the session user_id" do
        expect(session[:user_id]).to eq(activated_user.id)
      end

      it "redirects to the user's profile page" do
        expect(response).to redirect_to(user_path(activated_user, locale: default_locale))
      end
    end

    context "with invalid password" do
      before { post :create, params: { session: { email: activated_user.email, password: "wrongpassword" }, locale: default_locale } }

      it "does not set the session user_id" do
        expect(session[:user_id]).to be_nil
      end

      it "sets a danger flash message" do
        expect(flash.now[:danger]).to be_present
      end

      it "re-renders the new template" do
        expect(response).to render_template(:new)
      end

      it "returns an unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with unactivated account" do
       before { post :create, params: { session: { email: unactivated_user.email, password: "password123" }, locale: default_locale } }

      it "sets a warning flash message" do
        expect(flash[:warning]).to be_present
      end
       
      it "redirects to the login url" do
        expect(response).to redirect_to(login_url(locale: default_locale))
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user) }
    before do
      allow(controller).to receive(:logged_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      delete :destroy, params: { locale: default_locale }
    end

    it "clears the session" do
      expect(session[:user_id]).to be_nil
    end
    
    it "sets a success flash message" do
      expect(flash[:success]).to be_present
    end
    
    it "redirects to the login url" do
      expect(response).to redirect_to(login_url(locale: default_locale))
    end
  end
end
