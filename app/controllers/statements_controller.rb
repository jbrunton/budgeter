class StatementsController < ApplicationController
  before_action :set_project

  def index
    @statements = @project.statements.reverse
  end

  def show
    @statement = Statement.new(@project, Date.parse(params[:date]))

    first_date = @project.transactions.first.date.beginning_of_month
    last_date = @project.transactions.last.date
    @month_options = DateRange.new(first_date,last_date, true).to_a
      .map{ |date| [date.strftime('%b %Y'), date.strftime('%Y-%m-%d')] }
    @sort_options = [['Date', 'date'], ['Amount', 'amount']]
  end

  def transactions
    @statement = Statement.new(@project, Date.parse(params[:month]))

    @transactions = @project.transactions.within_month(Date.parse(params[:month]))
    if params[:sort_by] == 'amount'
      @transactions = @transactions.by_amount
    else
      @transactions = @transactions.by_date
    end

    render partial: 'shared/transactions_table',
      locals: { transactions: @transactions, editable: true, classify: Proc.new{ |t| t.categorized_status } }
  end

  def summary
    @statement = Statement.new(@project, Date.parse(params[:date]))
    render partial: 'shared/verification_status',
      locals: { verification_state: @statement.verification_state, show_unverified_spend: true }
  end

  def import

  end

  def upload
    upload = params[:statement]
    ext = File.extname(upload.original_filename)
    case
      when ext == '.csv'
        result = CurrentAccountParser.new(@project).parse(upload.tempfile)
      when ext == '.pdf'
        result = CreditCardParser.new(@project).parse(upload.tempfile)
      else
        raise "Unsupported file extension."
    end
    notice = "Imported #{result[:imported_transactions].count} transactions"
    notice << " (#{result[:duplicate_transactions].count} duplicates)" if result[:duplicate_transactions].any?
    redirect_to account_transactions_path(result[:account]), notice: notice
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end