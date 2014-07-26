require 'spec_helper'
require 'open3'

describe OriginalForge do
  let(:name) { 'African' }
  let(:forge) { described_class.new(name) }

  context 'validation' do
    context 'when spaces in user_name' do
      it 'raises an error' do
        expect {
          described_class.new('Joleine Simpson')
        }.to raise_error(ArgumentError)
      end
    end
  end

  it 'responds to attr_readers' do
    forge.user_name.should == name
  end

  it 'responds to #user_organization' do
    forge.send(:user_organization).should == 'FreeCinc'
  end

  describe '#generate_certificates' do
    it 'returns keys' do
      user_keys = forge.generate_certificates
      key = user_keys.key
      cert = user_keys.cert
      ca = user_keys.ca
      uuid = user_keys.uuid
      mirakel_config = user_keys.mirakel_config

      uuid.length.should == 36
      uuid.should be_a(String)

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

      expected_mirakel_config = <<EOF
username: #{forge.user_name}
org: #{forge.send(:user_organization)}
user key: #{uuid}
server: #{Forge::SERVER}
client.cert:
#{cert}
Client.key:
#{key}
ca.cert:
#{ca}
EOF
      mirakel_config.should == expected_mirakel_config
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




describe CopyForge do
  let(:any_uuid) { SecureRandom.uuid }

  context 'validation' do
    context 'when user_name is nil' do
      it 'raises an error' do
        expect {
          described_class.new(nil, 'something', any_uuid)
        }.to raise_error(ArgumentError)
      end
    end

    context 'when user_name is empty' do
      it 'raises an error' do
        expect {
          described_class.new('', 'something', any_uuid)
        }.to raise_error(ArgumentError)
      end
    end

    context 'when password is nil' do
      it 'raises an error' do
        expect {
          described_class.new('something', nil, any_uuid)
        }.to raise_error(ArgumentError)
      end
    end

    context 'when user_name is empty' do
      it 'raises an error' do
        expect {
          described_class.new('something', '', any_uuid)
        }.to raise_error(ArgumentError)
      end
    end

    context 'when both user_name and password have at least one character' do
      it 'raises no errors' do
        described_class.new('a', 'b', any_uuid)
      end
    end

    context 'when uuid is less than 36 characters' do
      it 'raises an error' do
        expect {
          described_class.new('something', 'something', 'abcdef')
        }.to raise_error(ArgumentError)
      end
    end
  end


  describe '.generate_password_from_user_name' do
    it do
      copy_forge = described_class.new('hungry_monkey', 'anything', any_uuid)
      copy_forge.send(:generate_password_from_user_name).should == 'a24bcb407e7aae39109dc8f85f12664347cead15'
    end
  end



  describe '.authenticated?' do

    context 'when username and password match' do
      it 'returns true' do
        # Note to get the correct password value, just change the SEED, run this test, and paste in what it expected
        copy_forge = described_class.new('hungry_monkey', 'a24bcb407e7aae39109dc8f85f12664347cead15', any_uuid)
        copy_forge.send(:authenticated?).should be_true
      end
    end

    context 'when username and password do not match' do
      it 'returns false' do
        # Note to get the correct password value, just change the SEED, run this test, and paste in what it expected
        copy_forge = described_class.new('not_a_hungry_monkey', 'a24bcb407e7aae39109dc8f85f12664347cead15', any_uuid)
        copy_forge.send(:authenticated?).should be_false
      end
    end
  end


  describe '.read_user_certificates' do

    subject { described_class.new(user_name, password, generated_certificates.uuid).read_user_certificates }

    let(:generated_user_name) { "test_#{SecureRandom.hex(4)}" }
    let(:user_name) { generated_user_name }
    let(:generated_certificates)  {OriginalForge.new(generated_user_name).generate_certificates }

    context 'when user_name exists' do

      context 'and password is valid' do
        let(:password) { described_class.new(user_name, 'anything', any_uuid).send(:generate_password_from_user_name) }
        it 'returns an OpenStruct' do
          subject.should be_a(OpenStruct)
          subject.should == generated_certificates
        end
      end

      context 'but the password is invalid' do
        let(:password) { 'valid' }
        it 'returns nil' do
          subject.should be_nil
        end
      end

    end
    context 'when user_name does not exist' do
      let(:user_name) { 'something_made_up' }
      let(:password) { 'anything' }
      it 'returns nil' do
        subject.should be_nil
      end
    end
  end
end
