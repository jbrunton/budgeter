class StatementsController < ApplicationController
  before_action :set_project

  def import

  end

  def upload
    imported_transactions = StatementParser.new(@project).parse(params[:statement].read)
    redirect_to account_transactions_path(imported_transactions.first.account), notice: "Imported #{imported_transactions.count} transactions."
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end