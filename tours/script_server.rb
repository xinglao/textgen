require 'redis'
require 'securerandom'

$redis = Redis.new
class ScriptServer < Tourist
  def tour_init_simple_script
    output = {
      "user_id" => SecureRandom.uuid,
      "message" => "TEST_HELLO",
      "script" => "test.rb",
      "script_url" => "https://gist.github.com/samnang/f643c373a0516e15d6ec/raw/e324f5b853a07db70ff3945288929047ff48dd66/test.rb",
      "script_version" => 1
    }

    $redis.publish('script_server_in', output.to_json)
  end
end
