require 'spec_helper'
require 'open3'

describe Forge do
  let(:name) { 'African' }
  let(:organization) { 'Folgers' }
  let(:forge) { described_class.new(name, organization) }

  context 'validation' do
    context 'when spaces in user_organization' do
      it 'raises and error' do
        expect {
          described_class.new(name, 'United Peace')
        }.to raise_error(ArgumentError)
      end
    end

    context 'when spaces in user_name' do
      it 'raises an error' do
        expect {
          described_class.new('Joleine Simpson', organization)
        }.to raise_error(ArgumentError)
      end
    end
  end

  it 'responds to attr_readers' do
    forge.user_name.should == name
    forge.user_organization.should == organization
  end

  describe '#generate_certificates' do
    it 'returns keys' do
      user_keys = forge.generate_certificates
      key = user_keys.key
      cert = user_keys.cert
      ca = user_keys.ca

      [key, cert].each do |thing|
        key.should include('BEGIN RSA PRIVATE KEY')
        key.should include('END RSA PRIVATE KEY')
      end

      ca.should include('BEGIN CERTIFICATE')
      ca.should include('END CERTIFICATE')

      [key, cert, ca].uniq.length.should == 3

      [key, cert, ca].each do |thing|
        (thing.length > 1400).should be_true
      end
    end

    it 'returns to SINATRA_ROOT' do
      forge.generate_certificates
      Dir.pwd.should == described_class::SINATRA_ROOT
    end
  end

  describe 'changing directory' do
    it 'changes back and forth between PKI_DIR and SINATRA_ROOT' do
      forge.send(:cd_to_pki_dir)
      Dir.pwd.should == described_class::PKI_DIR

      forge.send(:cd_to_sinatra_root)
      Dir.pwd.should == described_class::SINATRA_ROOT

      forge.send(:cd_to_pki_dir)
      Dir.pwd.should == described_class::PKI_DIR

      forge.send(:cd_to_sinatra_root)
      Dir.pwd.should == described_class::SINATRA_ROOT
    end
  end

  describe '#cd_to_pki_dir' do
    it 'arrives in the correct directory' do
      forge.send(:cd_to_pki_dir)
      Dir.pwd.should == described_class::PKI_DIR
    end
  end

  describe 'constants' do
    it 'has values' do
      described_class::TASKDDATA.should_not    be_nil
      described_class::INSTALL_DIR.should_not be_nil
      described_class::PKI_DIR.should_not     be_nil
    end
  end



  describe '#bash_with_tolerated_errors' do
    context 'with a reasonable command' do
      it 'does not blow up' do
        forge.send(:bash_with_tolerated_errors, 'ls')
      end
    end

    context 'with an unfound command' do
      it 'raises an error' do
        expect {
          forge.send(:bash_with_tolerated_errors, 'jabberwocky572')
        }.to raise_error(Errno::ENOENT)
      end
    end

    context 'with an found command that returns a non-zero exit status' do
      it 'dos not raise an error' do
        expect {
          forge.send(:bash_with_tolerated_errors, 'test -e jabberwocky572')
        }.to_not raise_error
      end
    end
  end

  describe '#bash' do
    context 'with a reasonable command' do
      it 'does not blow up' do
        forge.send(:bash, 'ls')
      end
    end

    context 'with an unfound command' do
      it 'raises an error' do
        expect {
          forge.send(:bash, 'jabberwocky572')
        }.to raise_error(Errno::ENOENT)
      end
    end

    context 'with an found command that returns a non-zero exit status' do
      it 'raises an error' do
        expect {
          forge.send(:bash, 'test -e jabberwocky572')
        }.to raise_error(ArgumentError)
      end
    end
  end

end
