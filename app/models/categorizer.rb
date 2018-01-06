class Categorizer
  attr_reader :project
  attr_reader :training_transactions
  attr_reader :test_transactions
  attr_reader :all_transactions
  attr_reader :scores

  def initialize(project)
    @project = project
  end

  def preview(seed, ignore_words)
    partition_transactions(seed)
    create_classifier(ignore_words)

    @test_transactions.each do |t|
      t.predicted_category = @classifier.classify(t.description)
    end

    @scores = Categorizer.score(@verifiable_transactions)
  end

  def apply(seed, ignore_words)
    partition_transactions(seed)
    create_classifier(ignore_words)

    @project.transactions.each do |t|
      t.predicted_category = @classifier.classify(t.description)
      t.save
    end
  end

  def self.score(transactions)
    puts "Scoring #{transactions.count} transactions"
    verifiable_transactions = transactions.select{ |t| t.categorized? }
    correct_transactions = verifiable_transactions.select { |t| t.assess_prediction == :correct }

    verifiable_amount = verifiable_transactions.map{ |t| t.value.abs }.reduce(:+)
    correct_amount = correct_transactions.map{ |t| t.value.abs }.reduce(:+)

    correct_transactions_score = (correct_transactions.count.to_f * 100 / verifiable_transactions.count).round
    correct_amount_score = (correct_amount * 100 / verifiable_amount).to_f.round

    {
      transactions: transactions,
      verifiable_transactions: verifiable_transactions,
      correct_transactions: correct_transactions,
      correct_amount_score: correct_amount_score,
      correct_transactions_score: correct_transactions_score
    }
  end

private
  def create_classifier(ignore_words)
    @classifier = StuffClassifier::Bayes.new('Transaction Classifier')
    @classifier.ignore_words = ignore_words.map{ |s| s.chomp }
    @training_transactions.each do |t|
      @classifier.train(t.category, t.description)
    end
  end

  def partition_transactions(seed)
    @verifiable_transactions = @project.transactions.select{ |t| t.categorized? }
    transactions_by_category = @verifiable_transactions.group_by{ |t| t.category }
    training_transactions = []
    test_transactions = []
    transactions_by_category.each do |_, ts|
      head, *tail = ts
      training_transactions << head
      test_transactions.concat tail
    end

    test_transactions.shuffle!(random: Random.new(seed))

    target_test_size = (@verifiable_transactions.count * 0.3)
    while test_transactions.size > target_test_size + 1
      training_transactions << test_transactions.pop
    end

    @test_transactions = test_transactions
    @training_transactions = training_transactions
  end
end