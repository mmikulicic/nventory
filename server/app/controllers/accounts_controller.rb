class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.xml
  def index
    includes = process_includes(Account, params[:include])
    
    sort = case params['sort']
           when "login" then "accounts.login"
           when "login_reverse" then "accounts.login DESC"
           end
    
    # if a sort was not defined we'll make one default
    if sort.nil?
      params['sort'] = Account.default_search_attribute
      sort = 'accounts.' + Account.default_search_attribute
    end
    
    # XML doesn't get pagination
    if params[:format] && params[:format] == 'xml'
      @objects = Account.find(:all,
                              :include => includes,
                              :order => sort)
    else
      @objects = Account.paginate(:all,
                                  :include => includes,
                                  :order => sort,
                                  :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects.to_xml(:include => convert_includes(includes),
                                                   :dasherize => false) }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    includes = process_includes(Account, params[:include])
    
    @account = Account.find(params[:id],
                            :include => includes)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account.to_xml(:include => convert_includes(includes),
                                                   :dasherize => false) }
    end
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to account_url(@account) }
        format.xml  { head :created, :location => account_url(@account) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to account_url(@account) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to accounts_url }
      format.xml  { head :ok }
    end
  end
  
  # GET /accounts/1/version_history
  def version_history
    @account = Account.find_with_deleted(params[:id])
    render :action => "version_table", :layout => false
  end
  
  # GET /accounts/field_names
  def field_names
    super(Account)
  end

  # GET /accounts/search
  def search
    @account = Account.find(:first)
    @exclude = ['password_hash', 'password_salt']
    render :action => 'search'
  end

end
