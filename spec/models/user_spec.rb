require 'spec_helper'
require 'bigdecimal'
require './models/user'

describe User do
  let(:user) { described_class.new }
  let(:array_of_certificates) { [user.key, user.cert, user.ca] }

  describe 'stubbed tests' do
    before do
      stub.any_instance_of(described_class).become_certified
    end

    describe '#name' do
      it 'has a name' do
        name = user.name
        name.should_not be_nil
        name.length.should == 13
      end
    end

    describe '#generate_unique_name' do
      # Monte Carlo simulation of collision rate.
      # Each monte carlo run creates 1000 user names
      # and then determines whethere there was a collision
      it 'less than 50% chance of a user name collision before ten thousand users reached' do
        beginning = Time.now
        monte_carlo_runs = 10

        collision = 'collision'
        no_collision = 'no collision'

        results = monte_carlo_runs.times.map do
          hash = {}
          single_result = no_collision
          10000.times do
            name = user.send(:generate_unique_name)
            single_result = collision if hash[name]
            hash[name] = 1
          end
          single_result
        end

        ending = Time.now
        elapsed_time = ending - beginning
        elapsed_time = '%.2f' % elapsed_time

        puts "*****   MONTE CARLO SIMULATION COMPLETED IN #{elapsed_time} SECONDS    *****"
        (results.count(no_collision) > results.count(collision)).should be_true;
      end
    end
  end

  context 'delegated methods' do

    it 'reponds to delegated methods' do
      array_of_certificates.each do |thing|
        thing.should be_a(String)
        (thing.length > 1400).should be_true
      end
    end

    it 'gives the same number each time' do
      array_of_certificates.each do |thing|
        first = thing.clone
        second = thing.clone
        first.object_id.should_not == second.object_id
        first.should == second
      end
    end
  end
end
