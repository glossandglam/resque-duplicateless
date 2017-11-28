# Load the basics
require "resque"
require "resque-duplicateless"
require "spec_helper"

# Setup Resque
Resque.redis = Redis.new

# Load the dummy worker
require "helper/dummy_worker"