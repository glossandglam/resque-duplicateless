# Load the basics
require "resque"
require "resque_unique_job"
require "spec_helper"

# Setup Resque
Resque.redis = Redis.new

# Load the dummy worker
require "helper/dummy_worker"