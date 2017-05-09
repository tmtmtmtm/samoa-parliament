#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  warn url
  noko = noko_for(url)
  noko.css('div.ngg-gallery-thumbnail a').each do |a|
    data = {
      id:    a.attr('data-image-id'),
      name:  a.attr('data-title'),
      image: a.attr('data-src'),
    }
    ScraperWiki.save_sqlite(%i[id name], data)
  end

  unless (next_page = noko.css('div.ngg-navigation a.next/@href')).empty?
    scrape_list(next_page.text) rescue binding.pry
  end
end

scrape_list('http://www.parliament.gov.ws/new/members-of-parliament/member/')
