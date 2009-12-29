require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/akismetor'

module AkismetorSpecHelper
  def valid_attributes
    {
      :key => 'YourApiKey', 
      :blog => 'http://www.my-site.com', 
      :user_ip => '200.10.20.30', 
      :user_agent => 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X 10.5; en-US; rv:1.9.0.3) Gecko/2008092414 Firefox/3.0.3', 
      :referrer => 'http://www.previous-site.com', 
      :permalink => 'http://www.my-site.com', 
      :comment_type => 'comment', 
      :comment_author => 'Joe Dude', 
      :comment_author_email => 'some-email@some-host.com', 
      :comment_author_url => 'http://www.author-s-site.com', 
      :comment_content => 'this is a normal comment'
    }
  end

  def invalid_attributes
    valid_attributes.with(:comment_author => 'viagra-test-123')
  end
end

describe Akismetor do
  include AkismetorSpecHelper

  describe "plugin requirements" do

    def mock_akismet(value)
      @response = stub("response", :body => value)
      @http = stub("http", :post => @response)
    end

    it ".spam? should convert provider's string 'true' to boolean true" do
      mock_akismet('true')
      Net::HTTP.should_receive(:new).and_return(@http)
      Akismetor.spam?(invalid_attributes).should be_true
    end

    it ".spam? should convert provier's string 'false' to boolean false" do
      mock_akismet('false')
      Net::HTTP.should_receive(:new).and_return(@http)
      Akismetor.spam?(invalid_attributes).should be_false
    end
    
    describe "with akismet" do
      before do
        @implicit_attributes = valid_attributes
        @explicit_attributes = valid_attributes.with(:provider => :akismet)
      end
      
      it ".valid_key? should connect to host 'rest.akismet.com' " do
        mock_akismet('true')
        Net::HTTP.should_receive(:new).exactly(:twice).with('rest.akismet.com', anything()).and_return(@http)
        Akismetor.valid_key?(@implicit_attributes)
        Akismetor.valid_key?(@explicit_attributes)
      end
      
      it ".spam? should connect to host 'YourApiKey.rest.akismet.com' " do
        mock_akismet('true')
        Net::HTTP.should_receive(:new).exactly(:twice).with('YourApiKey.rest.akismet.com', anything()).and_return(@http)
        Akismetor.spam?(@implicit_attributes)
        Akismetor.spam?(@explicit_attributes)
      end
    end
    
    describe "with typepad" do
      before do
        @attributes = valid_attributes.with(:provider => :typepad)
      end
      
      it ".valid_key? should connect to host 'api.antispam.typepad.com' " do
        mock_akismet('true')
        Net::HTTP.should_receive(:new).with('api.antispam.typepad.com', anything()).and_return(@http)
        Akismetor.valid_key?(@attributes)
      end
      
      it ".spam? should connect to host 'YourApiKey.api.antispam.typepad.com' " do
        mock_akismet('true')
        Net::HTTP.should_receive(:new).with('YourApiKey.api.antispam.typepad.com', anything()).and_return(@http)
        Akismetor.spam?(@attributes)
      end
    end
  end

  describe "provider commands" do

    before(:each) do
      @response = stub("response", :body => 'true')
      @http = stub("http", :post => @response)
      Net::HTTP.should_receive(:new).and_return(@http)
    end
    
    it ".valid_key? should run provider's command 'verify-key' " do
      @http.should_receive(:post).with('/1.1/verify-key', anything(), anything()).and_return(@response)
      Akismetor.valid_key?(valid_attributes)
    end

    it ".spam? should run provider's command 'comment-check' " do
      @http.should_receive(:post).with('/1.1/comment-check', anything(), anything()).and_return(@response)
      Akismetor.spam?(valid_attributes)
    end

    it ".submit_spam should run provider's command 'submit-spam' " do
      @http.should_receive(:post).with('/1.1/submit-spam', anything(), anything()).and_return(@response)
      Akismetor.submit_spam(valid_attributes)
    end

    it ".submit_ham should run provider's command 'submit-ham' " do
      @http.should_receive(:post).with('/1.1/submit-ham', anything(), anything()).and_return(@response)
      Akismetor.submit_ham(valid_attributes)
    end
  end
end
