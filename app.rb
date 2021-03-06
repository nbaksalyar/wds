require 'sinatra'
require 'aws/s3'
require 'yaml'

$cfg = YAML.load_file('config.yml')
AWS::S3::Base.establish_connection!(
  :access_key_id     => $cfg['access_key_id'],
  :secret_access_key => $cfg['secret_access_key'],
)
AWS::S3::DEFAULT_HOST.replace "#{$cfg['region']}.amazonaws.com"

get '/file' do
  status 201; headers "Cache-Control" => "no-cache"
  erb :show_file, :locals => { :full_address => 'http://' + $cfg['bucket'] + '.' + $cfg['region'] + '.amazonaws.com/' + params[:name] }
end

post '/upload' do
  AWS::S3::S3Object.store(
    params[:file][:filename],
    params[:file][:tempfile].read,
    $cfg['bucket'], :access => :public_read)
  redirect '/file?name=%s' % params[:file][:filename]
end

get '/' do erb :index end
