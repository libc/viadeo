module Viadeo
  module Api
    module QueryMethods

      def profile(access_token)
        simple_query(access_token, "/me", {})
      end

      def search_user(access_token, args)
        args = {} if args.nil?
        simple_query(access_token, "/search/users", args)
      end

      def simple_query(access_token, path, args)
        puts "simple_query(#{access_token}, #{path}, #{args})"

        resp = get path, {access_token: access_token}.merge(args)

        puts "Viadeo :: resp=#{resp.inspect}"

        resp.body
      end

      def simple_post_query(access_token, path, args, post_data = "")
        puts "simple_post_query(#{access_token}, #{path}, #{args})"

        resp = post path, {access_token: access_token}.merge(args), post_data

        puts "Viadeo :: resp=#{resp.inspect}"

        resp.body
      end

    end
  end
end
