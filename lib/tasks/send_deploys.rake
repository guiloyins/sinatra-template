require 'net/http'
namespace :dashboard do
  DEPLOY_PATH = 'http://dashboard.helabs.com.br/deploys'

  def send_deploys
    uri = URI(DEPLOY_PATH)
    res = Net::HTTP.post_form(uri, 'user_name' => DEV_NAME,
                                   'user_email' =>  DEV_EMAIL,
                                   'token' => TOKEN,
                                   'kind' => APP, 
                                   'hashed_code' => HASHED_CODE)
    p res
  end

  desc "Send deploys to Dashboard"
  task :send_deploys do
    send_deploys
  end
end

