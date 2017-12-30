class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :set_account

  # GET /transactions
  # GET /transactions.json
  def index
    @project = @account.project
    first_date = @account.transactions.first.date.beginning_of_month
    last_date = @account.transactions.last.date
    @month_options = DateRange.new(first_date,last_date, true).to_a
      .map{ |date| [date.strftime('%b %Y'), date.strftime('%Y-%m-%d')] }
    @sort_options = [['Date', 'date'], ['Amount', 'amount']]
  end

  def statement
    @transactions = @account.transactions.within_month(Date.parse(params[:month]))
    if params[:sort_by] == 'amount'
      @transactions = @transactions.by_amount
    else
      @transactions = @transactions.by_date
    end
    render layout: false
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
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.json { render json: @account.project.categories, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
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
      params.require(:transaction).permit(:date, :type, :description, :value, :balance, :category)
    end
end
