require "rails_helper"

RSpec.describe Admin::AdminUsersController, type: :controller do
  let!(:current_admin) { create(:user, :admin) }
  let!(:other_admin_active) { create(:user, :admin, activated: true) }
  let!(:other_admin_inactive) { create(:user, :admin, activated: false) }
  let!(:supervisor) { create(:user, :supervisor) }
  let(:default_locale) { I18n.default_locale }

  describe "GET #index" do
    context "when not logged in" do
      it "redirects to the login page" do
        get :index, params: { locale: default_locale }
        expect(response).to redirect_to(login_path(locale: default_locale))
      end
    end

    context "when logged in as a non-admin (supervisor)" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(supervisor)
      end

      it "redirects to the root path" do
        get :index, params: { locale: default_locale }
        expect(response).to redirect_to(root_path(locale: default_locale))
      end
    end

    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(current_admin)
        get :index, params: { locale: default_locale }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end

      it "assigns the admins" do
        expect(assigns(:admins)).to include(current_admin, other_admin_active, other_admin_inactive)
      end
    end
  end

  describe "POST #create" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(current_admin)
      end

      context "with valid attributes" do
        let(:valid_attributes) { attributes_for(:user, role: :admin) }
        let(:action) { post :create, params: { user: valid_attributes, locale: default_locale } }

        it "creates a new admin user" do
          expect { action }.to change(User.where(role: :admin), :count).by(1)
        end

        it "redirects to the admin index page" do
          action
          expect(response).to redirect_to(admin_admin_users_path(locale: default_locale))
        end
      end

      context "with invalid attributes" do
        let(:invalid_attributes) { attributes_for(:user, name: "", role: :admin) }
        let(:action) { post :create, params: { user: invalid_attributes, locale: default_locale } }

        it "does not create a new user" do
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
  end

  describe "PATCH #activate" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(current_admin)
        patch :activate, params: { id: other_admin_inactive.id, locale: default_locale }
      end
      
      it "activates an inactive admin" do
        expect(other_admin_inactive.reload.activated?).to be true
      end
    end
  end

  describe "PATCH #deactivate" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(current_admin)
        patch :deactivate, params: { id: other_admin_active.id, locale: default_locale }
      end
      
      it "deactivates an active admin" do
        expect(other_admin_active.reload.activated?).to be false
      end
    end
  end

  describe "DELETE #destroy" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(current_admin)
      end

      it "deletes another admin" do
        expect {
          delete :destroy, params: { id: other_admin_active.id, locale: default_locale }
        }.to change(User, :count).by(-1)
      end

      it "redirects to the index page" do
        delete :destroy, params: { id: other_admin_active.id, locale: default_locale }
        expect(response).to redirect_to(admin_admin_users_path(locale: default_locale))
      end
    end
  end

  describe "POST #promote" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(current_admin)
      end

      context "with a valid supervisor_id" do
        before { post :promote, params: { supervisor_id: supervisor.id, locale: default_locale } }

        it "promotes the supervisor to admin" do
          expect(supervisor.reload.admin?).to be true
        end

        it "redirects to the admin index page" do
          expect(response).to redirect_to(admin_admin_users_path(locale: default_locale))
        end
      end

      context "with an invalid supervisor_id" do
        before { post :promote, params: { supervisor_id: 9999, locale: default_locale } }

        it "does not change any roles" do
          expect(supervisor.reload.role).to eq("supervisor")
        end

        it "shows an alert" do
          expect(flash[:alert]).to be_present
        end
      end
    end
  end
end
