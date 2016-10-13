# Besides the ususal REST actions, this controller contains show_self,
# edit_self and update_self actions.
# This permits access to be explicitly controlled via the
# check_permissions filter, distinguishing between actions on one's own
# model vs. actions on other users' models.
class Admin::UsersController < ApplicationController
  #before_filter :not_logged_in_required, :only => [:new, :create]
  #before_filter :login_required, :only => [:show, :edit, :update]
  #before_filter :check_administrator_role, :only => [:index, :destroy, :enable]
  #before_filter :user_or_current_user, :only => [:show, :edit, :update]

  # activate is where a user with the correct activation code
  # is redirected to, so they can enter passwords and login name
  skip_before_action :check_permissions, :only=>[:activate, :signup, :new_password, :change_password, :register_new_token_request, :register_new_token_response]

  def index
    @users = User.
      active.
      joins("left join sessions on users.id = sessions.user_id").
      select("users.id as id, users.*, max(sessions.login_date) as last_login").
      group("users.id").
      order(:lastName, :firstName)
  end

  def show
    @user = User.find(params[:id])
  end

  def show_self
    @user = current_user
    render :template=>"users/show"
  end

  def new
    @user = User.new
    @user.user_roles.build
    @roles = Role.except_developer
  end

# users may only be created by the administrator from the index page
  def create
    cookies.delete :auth_token
    @user = User.new(user_params)
    @user.save!
    redirect_to admin_users_path
  rescue ActiveRecord::RecordInvalid
    flash[:error] = t('.record_invalid')
    @roles=Role.all
    render :action => 'new'
  end

  def edit # edit a user profile with id given
    @user = User.find(params[:id])
    @title = t('.heading', :name => @user.first_last_name)
  end

  def edit_self # edit profile of current user
    @user = current_user
    render :template => 'users/edit'
  end

  # account was created by admin and now user has entered and submitted username/password, with u2f registration data,
  # here we capture the user's public_key and public_key_handle
  def activate
    # TODO must remember to reset the session[:activation_code]
    user = User.find_and_activate!(params[:activation_code])
    if user.update_attributes(activation_params)
      flash[:notice] =t('admin.users.activate.activated')
      redirect_to root_path
    else
      flash[:warn] = user.errors.full_messages
      redirect_to signup_admin_user_path(user)
    end
  rescue User::BlankActivationCode
    flash[:notice] = t('.argument_error')
    redirect_to new_admin_user_path
  rescue User::ActivationCodeNotFound
    flash[:notice] = t('.not_found')
    redirect_to new_admin_user_path
  rescue User::AlreadyActivated
    flash[:notice] = t('.already_activated')
    redirect_to login_path
  end

  # after a password reset, show a form in which a user enters new password/password_confirmation values, login not required
  # authentication is based on password_reset_code, cf. original signup based on activation code.
  # if two-factor authentication is required, then a challenge is requested and response verified
  # This is the same as the activate method (above), but in the case of password reset, user is already active
  # and login name is not changed, only password.
  # response is handled by the admin/users#change_password action
  # new_password/change_password is analogous to signup/activate
  def new_password
    password_reset_code = params[:password_reset_code]
    @user = User.find_by_password_reset_code(password_reset_code)
  rescue User::BlankPasswordResetCode
    flash[:notice] = t('.flash_notice.invalid')
    redirect_to root_path
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = t('.flash_notice.not_found')
    redirect_to root_path
  end

  # new password values have been entered and we're going to save them here
  def change_password
    password_reset_code = params[:password_reset_code]
    u2f_sign_response = params[:user][:u2f_sign_response]
    @user = User.find_by_password_reset_code(password_reset_code)

    if @user.authenticated_token?( u2f_sign_response) && @user.update_attributes(params.require(:user).slice(:password, :password_confirmation).permit(:password, :password_confirmation))
      flash[:notice] = t('.flash_notice.no_errors')
      redirect_to root_path
    else
      render :new_password
    end

  rescue User::AuthenticationError => message
    flash[:notice] = message
    redirect_to root_path
  rescue User::BlankPasswordResetCode
    flash[:notice] = t('.flash_notice.invalid')
    redirect_to root_path
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = t('.flash_notice.not_found')
    redirect_to root_path
  end

  # authentication by replacement_token_registration_code attached to url
  # and by username/password login parameters
  # cf. UsersController#signup, where username and login are not known
  # user responds to the UsersController#register_new_token_response method
  def register_new_token_request
    @user = User.find_by_replacement_token_registration_code( params[:replacement_token_registration_code])
    @registerRequest = @user.register_request
  rescue ActiveRecord::RecordNotFound => message
    flash[:notice] = message
    redirect_to root_path
  rescue User::AuthenticationError => message
    flash[:notice] = message
    redirect_to root_path
  end

  def register_new_token_response
    #find by login params username/pw
    #todo better to include replacement_token_registration_code as an additional auth param
    user = User.find_and_authenticate_by_login_params(params[:user][:login], params[:user][:password])
    if user.update_attributes(activation_params.slice(:u2f_register_response).merge(:replacement_token_registration_code => nil))
      flash[:notice] =t('admin.users.register_new_token_response.registered')
      redirect_to root_path
    else
      flash[:warn] = user.errors.full_messages
      redirect_to root_path
    end
  rescue User::AuthenticationError => message
    flash[:error] = message
    redirect_to root_path
  end

  def update_self
    @user = User.find(current_user.id)
    if @user.update_attributes(user_params)
      flash[:notice] = t('.flash_notice')
      redirect_to admin_users_path
    else
      render :action => 'edit'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:notice] = t('.flash_notice')
      redirect_to admin_users_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.update_attribute(:status, "deleted")
    redirect_to admin_users_path
  end

  def disable
    @user = User.find(params[:id])
    unless @user.update_attribute(:enabled, false)
      flash[:error] = t('.flash_error')
    end
    redirect_to admin_users_path
  end

  def enable
    @user = User.find(params[:id])
    unless @user.update_attribute(:enabled, true)
      flash[:error] = t('.flash_error')
    end
    redirect_to admin_users_path
  end

  # we present a form for the user to enter login name and password
  # also register the user's token
  # user responds to the UsersController#activate method
  def signup
    @user = User.find(params[:id])
    @registerRequest = @user.register_request
    # template depends on two_factor_authentication enabled/disabled
    # it's for convenience, when we're running a demo and
    # tokens are not possible, for example
    render signup_template
  end

  # when a logged-in admin clicks "reset password"
  def send_change_password_email
    @user = User.find(params[:user_id])
    @user.prepare_to_send_reset_email
    @users = User.order("lastName, firstName").all
    if @user.save
      flash[:notice] = t('.flash_notice', :name => @user.first_last_name, :email => @user.email )
      redirect_to admin_users_path
    else
      flash[:error] = t('.flash_error', :name => @user.first_last_name, :email => @user.email)
      redirect_to admin_users_path
    end
  end

  # when a logged-in admin clicks "lost token"
  def send_lost_token_email
    @user = User.find(params[:user_id])
    @user.prepare_to_send_lost_token_email
    @users = User.order("lastName, firstName").all
    if @user.save
      flash[:notice] = t('.flash_notice', :name => @user.first_last_name, :email => @user.email )
      redirect_to admin_users_path
    else
      flash[:error] = t('.flash_error', :name => @user.first_last_name, :email => @user.email)
      redirect_to admin_users_path
    end
  end

protected

  def user_or_current_user
    if current_user.has_role?('administrator')
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

private
  def signup_template
    if TwoFactorAuthentication.enabled?
      'signup_with_two_factor_authentication'
    else
      'signup_without_two_factor_authentication'
    end
  end

  #def two_factor_authentication_required?
    #ENV.fetch("two_factor_authentication").blank? ||
      #ENV.fetch("two_factor_authentication") == 'enabled'
  #end

  def activation_params
    params.require(:user).
             slice(:login, :email, :password, :password_confirmation, :u2f_register_response).
             permit(:login, :email, :password, :password_confirmation, :u2f_register_response)
  end

  def user_params
    attrs = [ :email,
              :firstName,
              :lastName,
              :organization_id,
              :user_roles_attributes => [:role_id] ]
    params.require(:user).permit(attrs)
  end

end
