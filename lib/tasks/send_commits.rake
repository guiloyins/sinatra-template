require 'net/http'
namespace :dashboard do
  COMMITS_PATH = 'http://dashboard.helabs.com.br/commits'
  LOG_FILE = 'commits.log'
  CHAR_SPLIT = '|'

  def send_commits commits 
  end

  def make_commits_file
    system "git log --pretty=format:'%h | %an | %s | %ai | %ae' > commits.log" 
  end

  def send_commits
    uri = URI(COMMITS_PATH)
    commits = []
    open(LOG_FILE) do |f|
      10.times do
        line = f.gets || break
        commits << '{"id_commit" : "' + line.split(CHAR_SPLIT)[0].strip + '"' +
                   ', "author" : "' + line.split(CHAR_SPLIT)[1].strip + '"' +
                   ', "message" : "' + line.split(CHAR_SPLIT)[2].strip + '"' +
                   ', "date" : "' + line.split(CHAR_SPLIT)[3].strip + '"' +
                   ', "email" : "' + line.split(CHAR_SPLIT)[4].strip + '"}'
      end
    end
    res = Net::HTTP.post_form(uri, commits: commits.to_json,
                                     'token' => TOKEN, 
                                     'hashed_code' => HASHED_CODE)
  end

  def remove_commits_file
    File.delete(LOG_FILE)
  end

  desc "Send commits to Dashboard"
  task :send_commits do
    make_commits_file
    send_commits
    remove_commits_file
  end
end

