class UsersController < Spree::BaseController
  
  before_filter :login_required, :except => [:new, :create]
  before_filter :initialize_extension_partials
  before_filter :can_only_edit_self, :only => [:edit, :update, :show]
  
  resource_controller

  create.after do   
    self.current_user = @user       
  end

  create.response do |wants|  
    wants.html { redirect_back_or_default(products_path) }         
  end
  
  create do
    flash :user_created_with_success.l
  end
  
  protected
  
  def can_only_edit_self
    access_denied unless current_user.id == params[:id].to_i || current_user.has_role?("admin")
  end
  
end
