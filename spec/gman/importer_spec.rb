# frozen_string_literal: true

RSpec.describe Gman::Importer do
  let(:domains) { { 'test' => ['example.com'] } }
  let(:stdout) { StringIO.new }
  let(:logger) { Logger.new(@stdout) }
  let(:domain_list) { subject.domain_list }
  subject { described_class.new(domains) }

  before do
    subject.instance_variable_set '@logger', logger
  end

  it 'inits the domain list' do
    expect(domain_list).to be_a(Gman::DomainList)
    expect(domain_list.count).to eql(1)
    expect(domain_list.domains.first).to eql('example.com')
  end

  it 'inits the logger' do
    expect(subject.logger).to be_a(Logger)
  end

  it 'returns the current domain list' do
    expect(subject.current).to be_a(Gman::DomainList)
  end

  it 'returns the resolver' do
    expect(subject.resolver).to be_a(Resolv::DNS)
  end

  context 'domain rejection' do
    it 'returns false' do
      expect(subject.reject('example.com', 'reasons')).to eql(false)
    end

    it 'returns the reason why asked' do
      with_env 'RECONCILING', 'true' do
        expect(subject.reject('example.com', 'reasons')).to eql('reasons')
      end
    end
  end

  context 'manipulating the domain list' do
    context 'normalizing domains' do
      let(:domains) { { 'test' => ['www.EXAMPLE.com/'] } }
      before { subject.send :normalize_domains! }

      it 'normalizes the domains' do
        expect(domain_list.domains.first).to eql('example.com')
      end
    end

    context 'removing invalid domains' do
      let(:domains) { { 'test' => ['foo.github.io', 'example.com'] } }
      before { subject.send :ensure_validity! }

      it 'removes invalid domains' do
        expect(domain_list.count).to eql(1)
      end
    end
  end

  context 'with the current list stubbed' do
    let(:stubbed_list) { Gman::DomainList.new(path: stubbed_list_path) }
    let(:stubbed_file_contents) { File.read(stubbed_list_path) }
    before { subject.instance_variable_set '@current', stubbed_list }

    context 'writing' do
      before { @current = subject.current.to_s }
      before { subject.send :add_to_current }
      after  { File.write(stubbed_list_path, @current) }

      context 'adding domains' do
        let(:domains) do
          { 'test' => ['example.com'], 'test2' => ['github.com'] }
        end

        it 'adds the domains' do
          expected = "// test\nexample.com\n\n// test2\ngithub.com"
          expect(stubbed_file_contents).to match(expected)
        end
      end

      context 'importing' do
        let(:domains) do
          {
            'test' => ['www.example.com', 'foo.github.io'],
            'test2' => ['github.com', 'www.github.com', 'whitehouse.gov']
          }
        end
        before { subject.import(skip_resolve: true) }

        it 'imports' do
          expected = "// test\nexample.com\nfoo.github.io"
          expect(stubbed_file_contents).to match(expected)

          expected = "// test2\ngithub.com\nwhitehouse.gov"
          expect(stubbed_file_contents).to match(expected)
        end
      end
    end
  end

  context 'domain validation' do
    let(:domain) { '' }
    let(:valid?) { subject.send(:ensure_valid, domain) }

    context 'a valid domain' do
      let(:domain) { 'whitehouse.gov' }

      it 'is valid' do
        expect(valid?).to eql(true)
      end
    end

    {
      empty: '',
      blacklisted: 'egovlink.com',
      invalid: 'foo.invalid',
      academic: 'harvard.edu',
      "rejex'd": 'foo.github.io'
    }.each_key do |type|
      context "a #{type} domain" do
        it 'is invalid' do
          expect(valid?).to eql(false)
        end
      end
    end
  end

  context 'duplicate domains' do
    let(:dupe?) { subject.send(:dupe?, domain) }
    let(:ensure_not_dupe) { subject.send(:ensure_not_dupe, domain) }

    context 'a unique domain' do
      let(:domain) { 'gman.com' }

      it 'is not a dupe' do
        expect(dupe?).to be_falsy
        expect(ensure_not_dupe).to be_truthy
      end
    end

    context 'a duplicate domain' do
      let(:domain) { 'gov' }

      it "knows it's a dupe" do
        expect(dupe?).to be_truthy
        expect(ensure_not_dupe).to be_falsy
      end

      context 'a subdomain' do
        let(:domain) { 'whitehouse.gov' }

        it "know when a domain's a subdomain of an existing domain" do
          expect(dupe?).to be_truthy
          expect(ensure_not_dupe).to be_falsy
        end
      end
    end
  end

  context 'domain resolution' do
    let(:resolves?) { subject.domain_resolves?(domain) }
    let(:ensure_resolves) { subject.send(:ensure_resolves, domain) }

    context 'a valid domain' do
      let(:domain) { 'github.com' }

      it 'resolves' do
        expect(resolves?).to be_truthy
        expect(ensure_resolves).to be_truthy
      end
    end

    context 'an invalid domain' do
      let(:domain) { 'foo.invalid' }

      it "doesn't resolve" do
        expect(resolves?).to be_falsy
        expect(ensure_resolves).to be_falsy
      end
    end
  end

  context 'regex checks' do
    let(:ensure_regex) { subject.send(:ensure_regex, domain) }

    context 'valid domains' do
      let(:domain) { 'example.com' }

      it 'passes' do
        expect(ensure_regex).to be_truthy
      end
    end

    [
      'home.example.com', 'site.example.com', 'user.example.com',
      'foo.weebly.com', 'foo.wordpress.com', 'foo.govoffice.com',
      'foo.govoffice1.com', 'foo.homestead.com', 'foo.wix.com',
      'foo.blogspot.com', 'foo.tripod.com', 'foo.squarespace.com',
      'foo.github.io', 'ci.champaign.il.us'
    ].each do |domain|
      context "a #{domain} domain" do
        let(:domain) { domain }

        it 'rejects the domain' do
          expect(ensure_regex).to be_falsy
        end
      end
    end
  end

  context 'normalizing domains' do
    let(:normalized_domain) { subject.normalize_domain(domain) }

    [
      'http://example.com', 'www.example.com', 'example.com/',
      'example.com/foo', 'example.com/foo/', 'EXAMPLE.com'
    ].each do |domain|
      let(:domain) { domain }

      it 'normalizes the domain' do
        expect(normalized_domain).to eql('example.com')
      end
    end
  end
end
