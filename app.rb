require 'sinatra'
require 'fog'

$region  = 'eu-west-1'
$bucket  = 'unknown'
$fog     = Fog::Storage.new(
  :provider              => 'AWS',
  :aws_secret_access_key => '',
  :aws_access_key_id     => '',
  :region                => $region,
)

get '/file' do
  status 201; headers "Cache-Control" => "no-cache"
  filename = params[:name]
  erb :show_file, :locals => { :full_address => 'http://' + $bucket + '.s3-' + $region + '.amazonaws.com/' + filename }
end

post '/upload' do
  $fog.directories.get($bucket).files.create(
    :key    => params[:file][:filename],
    :body   => params[:file][:tempfile].read,
    :public => true,
  )
  redirect '/file?name=%s' % params[:file][:filename]
end

get '/' do erb :index end
