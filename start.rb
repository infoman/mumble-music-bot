#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require File.expand_path('../lib/settings', __FILE__)
require File.expand_path('../lib/music_bot', __FILE__)

bot = MusicBot.new
bot.start
