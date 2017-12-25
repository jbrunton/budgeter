class TrainingController < ApplicationController
  before_action :set_project
  before_action :set_random_seed

  def train
    partition = partition_transactions
    @test_transactions = partition[:test_transactions]
    @training_transactions = partition[:training_transactions]

    render 'train'
  end

  def update
    @project.ignore_words = params[:ignore_words]
    @project.save

    partition = partition_transactions
    @test_transactions = partition[:test_transactions]
    @training_transactions = partition[:training_transactions]

    classifier = StuffClassifier::Bayes.new('Transaction Classifier')
    classifier.ignore_words = @project.ignore_words.split(',').map{ |s| s.chomp }
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

  def set_random_seed
    @random_seed = if params[:random_seed].nil? then rand(999999) else params[:random_seed].to_i end
  end

  def partition_transactions
    categorised_transactions = @project.transactions.select{ |t| !t.category.nil? }
    transactions_by_category = categorised_transactions.group_by{ |t| t.category }
    training_transactions = []
    test_transactions = []
    transactions_by_category.each do |_, ts|
      head, *tail = ts
      training_transactions << head
      test_transactions.concat tail
    end

    test_transactions.shuffle!(random: Random.new(@random_seed))

    target_test_size = (categorised_transactions.count * 0.3)
    while test_transactions.size > target_test_size + 1
      training_transactions << test_transactions.pop
    end

    {
      test_transactions: test_transactions,
      training_transactions: training_transactions
    }
  end
end