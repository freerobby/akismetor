require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/akismetor'

module AkismetorSpecHelper
  def valid_attributes
    {
      :key => '123456789', 
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

  describe "in general" do

    def mock_akismet(value)
      @response = stub("response", :body => value)
      @http = stub("http", :post => @response)
    end

    it ".valid_key? should connect to host 'rest.akismet.com' " do
      mock_akismet('true')
      Net::HTTP.should_receive(:new).with('rest.akismet.com', anything()).and_return(@http)
      Akismetor.valid_key?(valid_attributes)
    end

    it ".spam? should connect to host '123456789.rest.akismet.com' " do
      mock_akismet('true')
      Net::HTTP.should_receive(:new).with('123456789.rest.akismet.com', anything()).and_return(@http)
      Akismetor.spam?(valid_attributes)
    end

    it ".spam? should convert Akismet's string 'true' to boolean true" do
      mock_akismet('true')
      Net::HTTP.should_receive(:new).and_return(@http)
      Akismetor.spam?(invalid_attributes).should be_true
    end

    it ".spam? should convert Akismet's string 'false' to boolean false" do
      mock_akismet('false')
      Net::HTTP.should_receive(:new).and_return(@http)
      Akismetor.spam?(invalid_attributes).should be_false
    end
  end

  describe "testing Akismet's commands" do

    before(:each) do
      @response = stub("response", :body => 'true')
      @http = stub("http", :post => @response)
      Net::HTTP.should_receive(:new).and_return(@http)
    end
    
    it ".valid_key? should run Akismet's command 'verify-key' " do
      @http.should_receive(:post).with('/1.1/verify-key', anything(), anything()).and_return(@response)
      Akismetor.valid_key?(valid_attributes)
    end

    it ".spam? should run Akismet's command 'comment-check' " do
      @http.should_receive(:post).with('/1.1/comment-check', anything(), anything()).and_return(@response)
      Akismetor.spam?(valid_attributes)
    end

    it ".submit_spam should run Akismet's command 'submit-spam' " do
      @http.should_receive(:post).with('/1.1/submit-spam', anything(), anything()).and_return(@response)
      Akismetor.submit_spam(valid_attributes)
    end

    it ".submit_ham should run Akismet's command 'submit-ham' " do
      @http.should_receive(:post).with('/1.1/submit-ham', anything(), anything()).and_return(@response)
      Akismetor.submit_ham(valid_attributes)
    end
  end
end
