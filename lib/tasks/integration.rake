# -*- encoding : utf-8 -*-
require 'pry'
namespace :integration do
  APP = 'atendesimples-ws'
  DEV_NAME = 'Rafael Fiuza'
  DEV_EMAIL = 'rafael.fiuza@helabs.com.br'
  HASHED_CODE = '4082c7ba48cc9f1327633723bf6743eb'
  TOKEN = 'iG7ttEDxmD6URq9IgFSBJw'

  def project_name
    File.expand_path(settings.root.gsub('/config','')).split("/").last
  end
  
  namespace :heroku do
    task :add_remote do
      remote = `git remote |grep heroku`
      sh "git remote add heroku git@heroku.com:#{APP}.git" if remote.strip.empty?
    end

    task :check do
      var = `heroku config -s --app #{APP}|grep INTEGRATING_BY`
      integrating_by = var != "" ? var.split('=')[1] : "" # Eu sei que é tosco, mas foda-se
      user = `whoami`
      if !integrating_by.empty? and integrating_by != user
        p80 "Project is already being integrated by #{integrating_by}"
        exit
      end
    end
    task :lock do
      user = `whoami`
      sh "heroku config:add INTEGRATING_BY=#{user}"
    end
    task :unlock do
      `heroku config:remove INTEGRATING_BY`
    end
  end
end

INTEGRATION_TASKS = %w(
  integration:heroku:add_remote
  integration:heroku:check
  integration:heroku:lock
  integration:start
  integration:bundle_install
  db:migrate
  spec
  integration:coverage_verify
  integration:finish
  heroku:deploy
  integration:heroku:unlock
  dashboard:send_scores
  dashboard:send_commits
  dashboard:send_deploys
)