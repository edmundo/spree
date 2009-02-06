class AddressesController < Spree::BaseController
  before_filter :load_related_data, :only => [:new, :create, :edit, :update]
  resource_controller
  belongs_to :user
  actions :all, :except => [:show, :index]
  
  new_action.before { build_new_presenter }
  create.before { build_new_presenter }
  edit.before { build_existing_presenter }
  update.before { build_existing_presenter }

  def create
    build_object
    load_object
    before :create

    object = @address_presenter.address
    object.addressable = @user

    if @address_presenter.valid? and object.save
      after :create
      redirect_to user_url(@user)
    else
      after :create_fails
      response_for :create_fails
    end
  end

  def update
    load_object
    before :update

    address = @address_presenter.address
    address.addressable = @user
    if @address_presenter.valid? and object.update_attributes address.attributes
      after :update
      redirect_to user_url(@user)
    else
      after :update_fails
      response_for :update_fails
    end
  end

  def destroy
    load_object
    before :destroy
    if object.destroy
      after :destroy
      redirect_to user_url(@user)
    else
      after :destroy_fails
      response_for :destroy_fails
    end
  end

  def country_changed
    country_id = params[:address_presenter][:address_country_id]
    @states = State.find_all_by_country_id(country_id, :order => 'name')
    render :partial => "shared/states", :locals => {:presenter_type => "address"}
  end
  
  private

  # Used together with actions that uses build_object.
  def build_new_presenter
    if params[:address_presenter]
      @address_presenter = AddressPresenter.new(params[:address_presenter])
    else
      @address_presenter = AddressPresenter.new(:address => Address.new(:country_id => @selected_country_id))
    end
  end

  def build_existing_presenter
    if params[:address_presenter]
      @address_presenter = AddressPresenter.new(params[:address_presenter])
    else
      @address_presenter = AddressPresenter.new(:address => object)
    end
  end

  def load_related_data
    @selected_country_id = params[:address_presenter][:address_country_id].to_i if params.has_key?('address_presenter')
    @selected_country_id ||= Spree::Config[:default_country_id]
    @states = State.find_all_by_country_id(@selected_country_id, :order => 'name')
    @countries = Country.find(:all)
  end

end