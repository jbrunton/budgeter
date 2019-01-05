class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :import_statement, :upload_statement]
  before_action :set_project

  def import_statement

  end

  def upload_statement
    uploads = params[:statements]
    total_imports = 0
    total_duplicates = 0
    uploads.each do |upload|
      ext = File.extname(upload.original_filename)
      case
        when ext == '.csv'
          result = CsvStatementParser.new(@account).parse(upload.tempfile)
        when ext == '.pdf'
          result = PdfStatementParser.new(@account).parse(upload.tempfile)
        else
          raise "Unsupported file extension."
      end
      total_imports += result[:imported_transactions].count
      total_duplicates += result[:duplicate_transactions].count
    end
    notice = "Imported #{total_imports} transactions"
    notice << " (#{total_duplicates} duplicates)" if total_duplicates > 0
    redirect_to account_transactions_path(@account), notice: notice
  end

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = @project.accounts
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = @project.accounts.build
    @record = [@project, @account]
  end

  # GET /accounts/1/edit
  def edit
    @record = @account
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = @project.accounts.build(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        @record = [@project, @account]
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to project_accounts_url(@project), notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  def set_project
    @project = @account.try(:project) || Project.find(params[:project_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def account_params
    params.require(:account).permit(:name, :account_type)
  end
end
