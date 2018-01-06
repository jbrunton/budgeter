class TrainingController < ApplicationController
  before_action :set_project
  before_action :set_random_seed

  def train
  end

  def preview
    @current_scores = Categorizer.score(@project.transactions)

    if @random_seed.nil?
      @training_transactions = []
      @test_transactions = @project.transactions.select{ |t| t.categorized? }
    else
      categorizer = Categorizer.new(@project)
      categorizer.preview(@random_seed, params[:ignore_words].split(','))

      @test_transactions = categorizer.test_transactions
      @training_transactions = categorizer.training_transactions
      @preview_scores = categorizer.scores

      @in_current_not_preview = @current_scores[:correct_transactions].select{ |t| !@preview_scores[:correct_transactions].collect(&:id).include?(t.id) }
      @in_preview_not_current = @preview_scores[:correct_transactions].select{ |t| !@current_scores[:correct_transactions].collect(&:id).include?(t.id) }
      # puts "in current not preview:"
      # puts @in_current_not_preview.map{|t| t.slice(:id, :description, :category, :predicted_category, :verified_category, :assess_prediction)}.to_yaml
      # puts "in preview not current:"
      # puts @in_preview_not_current.map{|t| t.slice(:id, :description, :category, :predicted_category, :verified_category, :assess_prediction)}.to_yaml
    end


    render layout: false
  end

  def classify
    categorizer = Categorizer.new(@project)
    categorizer.apply(@random_seed, params[:ignore_words].split(','))

    @project.seed = @random_seed
    @project.ignore_words = params[:ignore_words]
    @project.save

    redirect_to train_project_path(@project), notice: 'Transactions classified.'
  end

private
  def set_project
    @project = Project.find(params[:id])
  end

  def set_random_seed
    @random_seed = params[:random_seed].to_i unless params[:random_seed].blank?
  end
end