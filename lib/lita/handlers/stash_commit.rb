require 'json'

module Lita
  module Handlers
    class StashCommit < Handler
      http.post "/stash-post-receive", :receive

      def receive(request, response)
        room = request.params['room']
        target = Source.new(room: room)
        json_data = parse_json(request.body.read) or return
        message = format_message(json_data)
        robot.send_message(target, message)
      end

      def parse_json(json)
	JSON.parse(json)
      end

      def format_message(json)
         repo = "#{json['repository']['project']['name']}/#{json['repository']['name']}"
         csValues = json['changesets']['values']
         changes = ""
         csValues.each do |value|
           changes << " #{value['toCommit']['displayId']} by #{value['toCommit']['author']['name']}: #{value['toCommit']['message']}\n"
         end
        return "push to #{repo}\n#{changes}"
      end

      Lita.register_handler(self)
    end
  end
end
