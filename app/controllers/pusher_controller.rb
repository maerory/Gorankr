class PusherController < ApplicationController

    def auth
        
        pusher_client = Pusher::Client.new(
            app_id: ENV["PUSHER_APP_ID"],
            key: ENV["PUSHER_KEY"],
            secret: ENV["PUSHER_SECRET"],
            cluster: ENV["PUSHER_CLUSTER"]
        )
        if current_user
            response = pusher_client.authenticate(params[:channel_name], params[:socket_id], {
            user_id: current_user.id, # => required
            })
            render json: response
        else
            render text: 'Forbidden', status: '403'
        end
    end
end