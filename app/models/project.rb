class Project < ApplicationRecord
  def scan
    scan_dir = File.join(directory, 'statements')
    Dir.glob("#{scan_dir}/*.csv").map do |filename|
      Statement.new(filename: File.basename(filename))
    end
  end
end
