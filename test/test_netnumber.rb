require File.dirname(__FILE__) + '/test_helper.rb'
require 'rubygems'
require 'dnsruby'

class TestNetnumber < Test::Unit::TestCase

  def setup
  end
  
  def test_truth
    assert true
  end
  
  def test_netnumber_query
    n = Netnumber.new("8583361384")
    assert_equal(n.nnid, "100321")
  end
end
