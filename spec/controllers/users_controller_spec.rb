require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:default_locale) { I18n.default_locale }

  describe "GET #new" do
    before { get :new, params: { locale: default_locale } }

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "renders the new template" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_attributes) { attributes_for(:user) }
      let(:action) { post :create, params: { user: valid_attributes, locale: default_locale } }

      it "creates a new User in the database" do
        expect { action }.to change(User, :count).by(1)
      end

      it "redirects to the root url" do
        action
        expect(response).to redirect_to(root_url(locale: default_locale))
      end

      it "sets an info flash message" do
        action
        expect(flash[:info]).to be_present
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { attributes_for(:user, name: "") }
      let(:action) { post :create, params: { user: invalid_attributes, locale: default_locale } }

      it "does not save the new User" do
        expect { action }.not_to change(User, :count)
      end

      it "re-renders the 'new' template" do
        action
        expect(response).to render_template(:new)
      end

      it "returns an unprocessable_entity status" do
        action
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #show" do
    let(:user) { create(:user) }

    context "when not logged in" do
      it "redirects to the login page" do
        get :show, params: { id: user.id, locale: default_locale }
        expect(response).to redirect_to(login_path(locale: default_locale))
      end
    end

    context "when logged in" do
      before do
        # Trực tiếp stub authentication
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
        get :show, params: { id: user.id, locale: default_locale }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns the requested user to @user" do
        expect(assigns(:user)).to eq(user)
      end
    end
  end

  describe "PATCH #update" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context "when not logged in" do
      it "redirects to the login page" do
        patch :update, params: { id: user.id, user: { name: "New Name" }, locale: default_locale }
        expect(response).to redirect_to(login_path(locale: default_locale))
      end
    end

    context "when logged in" do
      before do
        # Trực tiếp stub authentication
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context "updating their own profile with valid data" do
        before { patch :update, params: { id: user.id, user: { name: "New Name" }, locale: default_locale } }

        it "updates the user's attributes" do
          expect(user.reload.name).to eq("New Name")
        end

        it "redirects to the profile page" do
          expect(response).to redirect_to(user_path(user, locale: default_locale))
        end

        it "sets a success flash message" do
          expect(flash[:success]).to be_present
        end
      end

      context "updating with invalid data" do
        before { patch :update, params: { id: user.id, user: { name: "" }, locale: default_locale } }

        it "does not update the user's attributes" do
          expect(user.reload.name).not_to eq("")
        end

        it "re-renders the edit page" do
          expect(response).to render_template(:edit)
        end
      end

      context "attempting to update another user's profile" do
        it "redirects to the root path" do
          patch :update, params: { id: other_user.id, user: { name: "Malicious" }, locale: default_locale }
          expect(response).to redirect_to(root_path(locale: default_locale))
        end
      end
    end
  end
end
