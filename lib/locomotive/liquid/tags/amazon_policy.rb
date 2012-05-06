require 'base64'
require 'openssl'
require 'digest/sha1'
#require 'liquid'

module Liquid
  module Locomotive
    module Tags
      class AmazonPolicy < ::Liquid::Tag

        #Syntax = /(#{::Liquid::Expression}+)?/

        #def initialize(tag_name, markup, tokens, context)
         # if markup =~ Syntax
         #   @user = $1.gsub('\'', '')
         # else
         #   raise ::Liquid::SyntaxError.new("Syntax Error in 'amazon_policy' - Valid syntax: amazon_policy <user>")
         # end

         # super
        #end

        def render(context)
	  date=(Time.now+180).utc.strftime("%Y-%m-%dT%H:%M:%SZ")
	  bucket=ENV["UPLOADS_BUCKET"]
	  redirect=ENV["REDIRECT_URL"]	
	  user=context.registers[:current_locomotive_account].email

          policy_document="""
			{\"expiration\": \"#{date}\",
  			 \"conditions\": [ 
						{\"bucket\": \"#{bucket}\"}, 
						[\"starts-with\", \"$key\", \"uploads/#{user}/\"],
						{\"acl\": \"private\"},
						{\"success_action_redirect\": \"#{redirect}\"},
						[\"starts-with\", \"$Content-Type\", \"\"]
  					]
			}
		"""
	  policy=Base64.encode64(policy_document).gsub("\n","")
	  signature = Base64.encode64(
    			OpenSSL::HMAC.digest(
        					OpenSSL::Digest::Digest.new('sha1'), 
        					ENV["S3_SECRET_KEY"], 
						policy
			)
    		      ).gsub("\n","")

	%{<input type='hidden' name='policy' value='#{policy}'>
      <input type='hidden' name='signature' value='#{signature}'>
	<div>#{policy_document}</div>}
        end
      end

      ::Liquid::Template.register_tag('amazon_policy', AmazonPolicy)
    end
  end
end

#Liquid::Template.parse('{%amazon_policy ciao%}').render(registers={:current_locomotive_account => {:email => "o"}})
