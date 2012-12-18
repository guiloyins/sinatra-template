require 'net/http'
namespace :dashboard do
  SCORE_PATH = 'http://dashboard.helabs.com.br/scores'
  
  def send_scores raw_data 
    uri = URI(SCORE_PATH)
    res = Net::HTTP.post_form(uri, 'raw_data' => raw_data, 'token' => TOKEN, 'hashed_code' => HASHED_CODE)
    
  end

  desc "Send scores to Dashboard"
  task :send_scores => "setup_stat" do
    @raw_data = CodeStatisticsScore.new(*STATS_DIRECTORIES).to_s
    send_scores @raw_data
  end

  class CodeStatisticsScore #:nodoc:
    TEST_TYPES = %w(Units Functionals Unit\ tests Functional\ tests Integration\ tests)

    def initialize(*pairs)
      @pairs      = pairs
      @statistics = calculate_statistics
      @total      = calculate_total if pairs.length > 1
      @return = ""
    end

    def to_s
      print_header
      @pairs.each { |pair| print_line(pair.first, @statistics[pair.first]) }
      print_splitter

      if @total
        print_line("Total", @total)
        print_splitter
      end

      print_code_test_stats
    end

    private
    def calculate_statistics
      Hash[@pairs.map{|pair| [pair.first, calculate_directory_statistics(pair.last)]}]
    end

    def calculate_directory_statistics(directory, pattern = /.*\.rb$/)
      stats = { "lines" => 0, "codelines" => 0, "classes" => 0, "methods" => 0 }

      Dir.foreach(directory) do |file_name|
        if File.directory?(directory + "/" + file_name) and (/^\./ !~ file_name)
          newstats = calculate_directory_statistics(directory + "/" + file_name, pattern)
          stats.each { |k, v| stats[k] += newstats[k] }
        end

        next unless file_name =~ pattern

        f = File.open(directory + "/" + file_name)
        comment_started = false
        while line = f.gets
          stats["lines"]     += 1
          if(comment_started)
            if line =~ /^=end/
              comment_started = false
            end
            next
          else
            if line =~ /^=begin/
              comment_started = true
              next
            end
          end
          stats["classes"]   += 1 if line =~ /^\s*class\s+[_A-Z]/
          stats["methods"]   += 1 if line =~ /^\s*def\s+[_a-z]/
          stats["codelines"] += 1 unless line =~ /^\s*$/ || line =~ /^\s*#/
        end
      end

      stats
    end

    def calculate_total
      total = { "lines" => 0, "codelines" => 0, "classes" => 0, "methods" => 0 }
      @statistics.each_value { |pair| pair.each { |k, v| total[k] += v } }
      total
    end

    def calculate_code
      code_loc = 0
      @statistics.each { |k, v| code_loc += v['codelines'] unless TEST_TYPES.include? k }
      code_loc
    end

    def calculate_tests
      test_loc = 0
      @statistics.each { |k, v| test_loc += v['codelines'] if TEST_TYPES.include? k }
      test_loc
    end

    def print_header
      print_splitter
      @return << "| Name                 | Lines |   LOC | Classes | Methods | M/C | LOC/M |"
      print_splitter
    end

    def print_splitter
      @return << "+----------------------+-------+-------+---------+---------+-----+-------+"
    end

    def print_line(name, statistics)
      m_over_c   = (statistics["methods"] / statistics["classes"])   rescue m_over_c = 0
      loc_over_m = (statistics["codelines"] / statistics["methods"]) - 2 rescue loc_over_m = 0

      start = if TEST_TYPES.include? name
        "| #{name.ljust(20)} "
      else
        "| #{name.ljust(20)} "
      end

      @return << start +
        "| #{statistics["lines"].to_s.rjust(5)} " +
        "| #{statistics["codelines"].to_s.rjust(5)} " +
        "| #{statistics["classes"].to_s.rjust(7)} " +
        "| #{statistics["methods"].to_s.rjust(7)} " +
        "| #{m_over_c.to_s.rjust(3)} " +
        "| #{loc_over_m.to_s.rjust(5)} |"
    end

    def print_code_test_stats
      code  = calculate_code
      tests = calculate_tests

      @return << "  Code LOC: #{code}     Test LOC: #{tests}     Code to Test Ratio: 1:#{sprintf("%.1f", tests.to_f/code)}"
      @return << ""
    end
  end

  task :setup_stat do
    ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
    ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
    ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
    ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
    ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
    ::STATS_DIRECTORIES << %w(Mailer\ specs spec/mailers) if File.exist?('spec/mailers')
    ::STATS_DIRECTORIES << %w(Routing\ specs spec/routing) if File.exist?('spec/routing')
    ::STATS_DIRECTORIES << %w(Request\ specs spec/requests) if File.exist?('spec/requests')
    ::CodeStatisticsScore::TEST_TYPES << "Model specs" if File.exist?('spec/models')
    ::CodeStatisticsScore::TEST_TYPES << "View specs" if File.exist?('spec/views')
    ::CodeStatisticsScore::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
    ::CodeStatisticsScore::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
    ::CodeStatisticsScore::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
    ::CodeStatisticsScore::TEST_TYPES << "Mailer specs" if File.exist?('spec/mailers')
    ::CodeStatisticsScore::TEST_TYPES << "Routing specs" if File.exist?('spec/routing')
    ::CodeStatisticsScore::TEST_TYPES << "Request specs" if File.exist?('spec/requests')
  end
end

