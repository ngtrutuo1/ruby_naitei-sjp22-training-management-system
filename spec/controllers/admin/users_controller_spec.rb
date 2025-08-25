require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let!(:admin) { create(:user, :admin) }
  let!(:supervisor_active) { create(:user, :supervisor, activated: true) }
  let!(:supervisor_inactive) { create(:user, :supervisor, activated: false) }
  let!(:trainee) { create(:user, :trainee) }
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
        allow(controller).to receive(:current_user).and_return(supervisor_active)
      end

      it "redirects to the root path" do
        get :index, params: { locale: default_locale }
        expect(response).to redirect_to(root_path(locale: default_locale))
      end
    end

    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(admin)
        get :index, params: { locale: default_locale }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        expect(response).to render_template(:index)
      end

      it "assigns the supervisors" do
        expect(assigns(:supervisors)).to include(supervisor_active, supervisor_inactive)
      end
    end
  end

  describe "GET #new_supervisor" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(admin)
        get :new_supervisor, params: { locale: default_locale }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns trainees" do
        expect(assigns(:user_trainees)).to include(trainee)
      end
    end
  end

  describe "PATCH #update" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(admin)
      end

      context "with valid parameters" do
        before { patch :update, params: { id: supervisor_active.id, user: { name: "New Sup Name" }, locale: default_locale } }

        it "updates the supervisor's name" do
          expect(supervisor_active.reload.name).to eq("New Sup Name")
        end

        it "redirects to the supervisor's show page" do
          expect(response).to redirect_to(admin_user_path(supervisor_active, locale: default_locale))
        end
      end

      context "with invalid parameters" do
        before { patch :update, params: { id: supervisor_active.id, user: { name: "" }, locale: default_locale } }

        it "does not update the supervisor" do
          expect(supervisor_active.reload.name).not_to eq("")
        end

        it "re-renders the show page" do
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe "PATCH #add_role_supervisor" do
    context "when logged in as an admin" do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(admin)
      end

      context "with selected trainee_ids" do
        before { patch :add_role_supervisor, params: { supervisor_ids: [trainee.id], locale: default_locale } }

        it "promotes the selected trainee to supervisor" do
          expect(trainee.reload.supervisor?).to be true
        end

        it "sets a success flash message" do
          expect(flash[:success]).to be_present
        end

        it "redirects to the new_supervisor page" do
          expect(response).to redirect_to(new_supervisor_admin_users_path(locale: default_locale))
        end
      end

      context "with no trainees selected" do
        it "redirects to the new_supervisor page" do
          patch :add_role_supervisor, params: { supervisor_ids: [], locale: default_locale }
          expect(response).to redirect_to(new_supervisor_admin_users_path(locale: default_locale))
        end
      end
    end
  end
end
