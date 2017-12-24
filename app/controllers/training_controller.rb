class TrainingController < ApplicationController
  before_action :set_project, only: [:preview, :train]

  def preview
    categorised_transactions = @project.transactions.select{ |t| !t.category.nil? }
    @training_transactions = categorised_transactions.each_with_index.select{ |_, i| i % 3 != 0 }.map{ |t, _| t }
    @test_transactions = categorised_transactions.each_with_index.select{ |_, i| i % 3 == 0 }.map{ |t, _| t }

    render 'train'
  end

  def train
    categorised_transactions = @project.transactions.select{ |t| !t.category.nil? }
    @training_transactions = categorised_transactions.each_with_index.select{ |_, i| i % 3 != 0 }.map{ |t, _| t }
    @test_transactions = categorised_transactions.each_with_index.select{ |_, i| i % 3 == 0 }.map{ |t, _| t }

    classifier = StuffClassifier::Bayes.new('Transaction Classifier')
    @training_transactions.each do |t|
      classifier.train(t.category, t.description)
    end

    @test_transactions.each do |t|
      t.predicted_category = classifier.classify(t.description)
    end

    @score = (@test_transactions.select{ |t| t.predicted_category == t.category }.count.to_f * 100 / @test_transactions.count).round

    render 'train'
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end