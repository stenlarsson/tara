# encoding: utf-8

require 'spec_helper'


module Tara
  describe Fetcher do
    let :fetcher do
      described_class.new(download_dir, 'osx', '20150210', tr_release_url: 'http://localhost:8888/releases')
    end

    let :download_dir do
      Dir.mktmpdir
    end

    let :tr_archive_name do
      'traveling-ruby-20150210-2.2.0-osx.tar.gz'
    end

    let :tr_gem_name do
      'traveling-ruby-gems-20150210-2.2.0-osx/thin-1.6.3.tar.gz'
    end

    after do
      FileUtils.remove_entry_secure(download_dir)
    end

    describe '#fetch_ruby' do
      context 'when the specified Ruby version exist' do
        let :local_uri do
          'ruby-20150210-2.2.0-osx.tar.gz'
        end

        before do
          stub_request(:get, %(http://localhost:8888/releases/#{tr_archive_name}))
            .to_return(:body => 'fake', status: 200, headers: { 'Content-Length' => 4 })
        end

        it 'downloads the archive' do
          fetcher.fetch_ruby
          expect(File.read(File.join(download_dir, local_uri))).to eq('fake')
        end

        it 'returns the path where it was downloaded' do
          path = fetcher.fetch_ruby
          expect(path).to eq(File.join(download_dir, local_uri))
        end
      end

      context 'when the specified Ruby version does not exist' do
        before do
          stub_request(:get, %(http://localhost:8888/releases/#{tr_archive_name}))
            .to_return(status: 404)
        end

        it 'throws an error' do
          expect { fetcher.fetch_ruby }.to raise_error(Tara::NotFoundError, %(#{tr_archive_name} doesn't exist))
        end
      end

      context 'when the specified Ruby version exists at a different location' do
        pending 'deal with redirects'
      end
    end

    describe '#fetch_native_gem' do
      context 'when the specified version exist' do
        let :local_uri do
          'thin-1.6.3-20150210-2.2.0-osx.tar.gz'
        end

        before do
          stub_request(:get, %(http://localhost:8888/releases/#{tr_gem_name}))
            .to_return(:body => 'fake', status: 200, headers: { 'Content-Length' => 4 })
        end

        it 'downloads the archive' do
          fetcher.fetch_native_gem('thin', '1.6.3')
          expect(File.read(File.join(download_dir, local_uri))).to eq('fake')
        end

        it 'returns the path where it was downloaded' do
          path = fetcher.fetch_native_gem('thin', '1.6.3')
          expect(path).to eq(File.join(download_dir, local_uri))
        end
      end

      context 'when the specified version does not exist' do
        before do
          stub_request(:get, %(http://localhost:8888/releases/#{tr_gem_name}))
            .to_return(status: 404)
        end

        it 'throws an error' do
          expect { fetcher.fetch_native_gem('thin', '1.6.3') }.to raise_error(Tara::NotFoundError, %(#{tr_gem_name} doesn't exist))
        end
      end

      context 'when the specified version exists at a different location' do
        pending 'deal with redirects'
      end
    end
  end
end
