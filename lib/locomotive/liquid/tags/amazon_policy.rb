require 'date'

module Liquid
  module Locomotive
    module Tags
      class AmazonPolicy < ::Liquid::Tag

        Syntax = /(#{::Liquid::Expression}+)?/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @user = $1.gsub('\'', '')
	    @redirect = $2.gsub('\'', '')
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'amazon_policy' - Valid syntax: amazon_policy <user> <redirect_url>")
          end

          super
        end

        def render(context)
          %{
          	{"expiration": DateTime.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
  	   	 "conditions": [ 
    				{"bucket": #{$ENV["S3_BUCKET"]}}, 
    				["starts-with", "$key", 'uploads/#{@user}/'],
    				{"acl": "private"},
    				{"success_action_redirect": '#{@redirect}'}
  		 ]
		}
	   }
        end
      end

      ::Liquid::Template.register_tag('amazon_policy', AmazonPolicy)
    end
  end
end
