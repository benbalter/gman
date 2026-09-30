# frozen_string_literal: true

RSpec.describe Gman do
  context 'valid domains' do
    ['foo.gov', 'http://foo.mil', 'foo@bar.gc.ca', 'foo.gov.au',
     'https://www.foo.gouv.sn', 'https://www.foo.gouv.fr',
     'foo@ci.champaign.il.us', 'foo.fed.us',
     'foo.bar.baz.gov.au', 'foo@bar.gov.uk', 'foo.gov',
     'bensenville.il.us', 'foo.state.il.us', 'state.il.us',
     'foo@af.mil', 'foo.gov.in', 'user@state.il.us', 'user@ci.austin.tx.us',
     'user@sub.co.somewhere.ca.us', 'www.ci.foo.il.us'].each do |domain|
       subject { described_class.new(domain) }

       it "knows #{domain.inspect} is valid government domain" do
         expect(described_class.valid?(domain)).to be(true)
         expect(subject.valid?).to be(true)
       end
     end
  end

  context 'invalid domains' do
    ['foo.bar.com', 'bar@foo.biz', 'http://www.foo.biz',
     'foo.uk', 'gov', 'foo@k12.champaign.il.us', # 'foo@kii.gov.by',
     'foo', '', nil, ' ', 'foo.city.il.us', 'foo.ci.il.us',
     'foo.zx.us', 'foo@mail.gov.ua', 'foo@gwu.edu',
     'user@state.il.us.attacker.com', 'user@ci.foo.il.us.attacker.com',
     'user@state.ca.usattacker.com', 'user@state.ca.usa-attacker.com',
     'user@dst.ny.us.evil.co.uk', 'state.il.us.attacker.com',
     'https://state.il.us.attacker.com/path'].each do |domain|
      subject { described_class.new(domain) }

      it "knows #{domain.inspect} is not a valid government domain" do
        expect(described_class.valid?(domain)).to be(false)
        expect(subject.valid?).to be(false)
      end
    end
  end

  context 'when an email address hides a government host' do
    [
      '"x@gsa.gov#"@evil.com', '"x@gsa.gov?"@evil.com', '"x@gsa.gov/"@evil.com',
      'x@gsa.gov#@evil.com', "attacker@evil.com\nx@gsa.gov",
      "attacker@evil.com\rx@gsa.gov", "attacker@evil.com\tx@gsa.gov",
      "attacker@evil.com\0x@gsa.gov", "attacker@evil.com\u00a0x@gsa.gov",
      'attacker@evil.com x@gsa.gov', 'evil.com/@gsa.gov', 'evil.com?@gsa.gov',
      'evil.com#@gsa.gov'
    ].each do |input|
      it "knows #{input.inspect} is not a valid government domain" do
        gman = described_class.new(input)
        expect(gman.domain).to be_nil
        expect(gman.valid?).to be(false)
        expect(described_class.valid?(input)).to be(false)
      end
    end

    it 'uses the URL host when given a URL with an @ in the path' do
      gman = described_class.new('https://evil.com/@gsa.gov')
      expect(gman.domain.to_s).to eql('evil.com')
      expect(gman.valid?).to be(false)
    end
  end

  context 'when given an email address or URL' do
    {
      'foo@bar.gov' => 'bar.gov', ' FOO@BAR.GOV ' => 'bar.gov',
      'foo@ci.champaign.il.us' => 'ci.champaign.il.us', 'foo@bar.gc.ca' => 'bar.gc.ca',
      'mailto:foo@bar.gov' => 'bar.gov', 'foo.gov/path' => 'foo.gov',
      'https://user@foo.gov/path' => 'foo.gov', 'http://user:pw@foo.gov/x?y#z' => 'foo.gov'
    }.each do |input, host|
      it "extracts #{host} from #{input.inspect}" do
        gman = described_class.new(input)
        expect(gman.domain.to_s).to eql(host)
        expect(gman.valid?).to be(true)
      end
    end
  end

  context 'when a domain is on both the government and academic lists' do
    subject { described_class.new('foo.gov') }

    let(:academic_list) { Gman::DomainList.from_hash('academic' => ['foo.gov']) }

    before { allow(described_class).to receive(:academic_list).and_return(academic_list) }

    it 'is not a valid government domain' do
      expect(subject.valid?).to be(false)
    end
  end

  context 'localities' do
    subject { described_class.new(domain) }

    context 'when given github.gov' do
      let(:domain) { 'github.gov' }

      it "knows it's not a locality" do
        expect(subject.locality?).to be(false)
      end
    end

    context 'when given foo.state.il.us' do
      let(:domain) { 'foo.state.il.us' }

      it "knows it's a locality" do
        expect(subject.locality?).to be(true)
      end
    end

    ['state.il.us.attacker.com', 'ci.foo.il.us.attacker.com',
     'state.ca.usattacker.com', 'user@state.il.us.attacker.com'].each do |attacker_domain|
      context "when given #{attacker_domain}" do
        let(:domain) { attacker_domain }

        it "knows it's not a locality" do
          expect(subject.locality?).to be(false)
        end

        it 'has no locality type or state' do
          expect(subject.type).to be_nil
          expect(subject.state).to be_nil
        end
      end
    end
  end

  context 'class methods' do
    it 'returns the domain list' do
      expect(described_class.list).to be_a(Gman::DomainList)
    end

    it 'returns the academic list' do
      expect(described_class.academic_list).to be_a(Gman::DomainList)
    end

    it 'returns the config path' do
      expect(Dir.exist?(described_class.config_path)).to be(true)
    end

    it 'returns the list path' do
      expect(File.exist?(described_class.list_path)).to be(true)
    end

    it 'returns the academic list path' do
      expect(File.exist?(described_class.academic_list_path)).to be(true)
    end
  end
end
