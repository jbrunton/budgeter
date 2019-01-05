class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy, :verify]
  before_action :set_account

  include TransactionsHelper

  # GET /transactions
  # GET /transactions.json
  def index
    @project = @account.project
    @month_options = month_options_for(@project)
  end

  def statement
    @transactions = @account.transactions.within_month(Date.parse(params[:month]))
    if params[:sort_by] == 'amount'
      @transactions = @transactions.by_amount
    else
      @transactions = @transactions.by_date
    end

    render partial: 'shared/transactions_table',
      locals: { transactions: @transactions, editable: true, classify: Proc.new{ |t| t.categorized_status } }
  end

  def statement_summary
    @transactions = @account.transactions.within_month(Date.parse(params[:month]))

    verification_state = VerificationState.new(@transactions).compute_state

    render partial: 'shared/verification_status',
      locals: { verification_state: verification_state, show_unverified_spend: true }
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    update_transaction { @transaction.update(transaction_params) }
  end

  def verify
    update_transaction { @transaction.verify(verified) }
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url, notice: 'Transaction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def sync_confirm
    @transactions = Transaction.pending
  end

  def sync
    @pending_transactions = Transaction.pending
    @duplicate_transactions = []
    @saved_transactions = []
    @pending_transactions.each do |t|
      begin
        t.status = if t.category.nil? then :unclassified else :training end
        t.save
        @saved_transactions << t
      rescue ActiveRecord::RecordNotUnique => e
        @duplicate_transactions << t
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def set_account
      @account = @transaction.try(:account) || Account.find(params[:account_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:assigned_category)
    end

    def verified
      ActiveRecord::Type::Boolean.new.deserialize(params.require(:transaction).permit(:verified)[:verified])
    end

    def update_transaction
      respond_to do |format|
        if yield()
          format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
          format.json { render 'transactions/show.json.jbuilder' }
        else
          format.html { render :edit }
          format.json { render json: @transaction.errors, status: :unprocessable_entity }
        end
      end
    end
end
