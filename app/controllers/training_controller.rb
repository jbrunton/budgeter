class TrainingController < ApplicationController
  before_action :set_project
  before_action :set_random_seed

  def train
    @current_score = Categorizer.score(@project.transactions.select{ |t| t.verified || !t.category.blank? })
  end

  def preview
    if @random_seed.nil?
      @training_transactions = []
      @test_transactions = @project.transactions.select{ |t| t.verified || !t.category.blank? }
      @score = Categorizer.score(@test_transactions)
    else
      categorizer = Categorizer.new(@project)
      categorizer.preview(@random_seed, params[:ignore_words].split(','))

      @test_transactions = categorizer.test_transactions
      @training_transactions = categorizer.training_transactions
      @score = categorizer.score
    end

    render layout: false
  end

  def classify
    categorizer = Categorizer.new(@project)
    categorizer.apply(@random_seed, params[:ignore_words].split(','))

    @project.seed = @random_seed
    @project.ignore_words = params[:ignore_words]

    redirect_to @project, notice: 'Transactions classified.'
  end

private
  def set_project
    @project = Project.find(params[:id])
  end

  def set_random_seed
    @random_seed = params[:random_seed].to_i unless params[:random_seed].blank?
  end
end