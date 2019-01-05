class StatementsController < ApplicationController
  before_action :set_project

  def index
    @statements = @project.statements.reverse
  end

  def show
    @statement = Statement.new(@project, Date.parse(params[:date]))
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
private
  def set_project
    @project = Project.find(params[:id])
  end
end