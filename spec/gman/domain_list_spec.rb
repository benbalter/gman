# frozen_string_literal: true

RSpec.describe Gman::DomainList do
  let(:data) { subject.data }
  let(:canada) { data['Canada municipal'] }

  %i[path contents data].each do |type|
    context "when initialized by #{type}" do
      subject do
        case type
        when :path
          described_class.new(path: Gman.list_path)
        when :contents
          contents = File.read(Gman.list_path)
          described_class.new(contents: contents)
        when :data
          data = described_class.new(path: Gman.list_path).to_h
          described_class.new(data: data)
        end
      end

      it 'stores the init var' do
        expect(subject.send(type)).not_to be_nil
      end

      it 'returns the domain data' do
        expect(data).to have_key('Canada federal')
        expect(data.values.flatten).to include('gov')
      end

      it 'returns the list contents' do
        expect(subject.contents).to match(/^gov$/)
      end

      it 'knows the list path' do
        expect(subject.path).to eql(Gman.list_path)
      end

      it 'returns the PublicSuffix list' do
        expect(subject.public_suffix_list).to be_a(PublicSuffix::List)
      end

      it 'knows if a domain is valid' do
        expect(subject.valid?('whitehouse.gov')).to be(true)
      end

      it 'knows if a domain is invalid' do
        expect(subject.valid?('example.com')).to be(false)
      end

      it 'returns the domain groups' do
        expect(subject.groups).to include('Canada federal')
      end

      it 'returns the domains' do
        expect(subject.domains).to include('gov')
      end

      it 'returns the domain count' do
        expect(subject.count).to be_a(Integer)
        expect(subject.count).to be > 100
      end

      it 'alphabetizes the list' do
        canada.shuffle!
        expect(canada.first).not_to eql('100milehouse.com')
        subject.alphabetize
        expect(canada.first).to eql('100milehouse.com')
      end

      it 'outputs public suffix format' do
        expect(subject.to_s).to match("// Canada federal\ncanada.ca\n")
      end

      it "finds a domain's parent" do
        expect(subject.parent_domain('foo.gov.uk')).to eql('gov.uk')
      end

      context 'with the list path stubbed' do
        let(:stubbed_file_contents) { File.read(stubbed_list_path) }

        before do
          subject.instance_variable_set(:@path, stubbed_list_path)
        end

        context 'with list data stubbed' do
          before do
            subject.data = { 'foo' => ['!mail.bar.gov', 'bar.gov', 'baz.net'] }
          end

          context 'alphabetizing' do
            before { subject.alphabetize }

            it 'puts exceptions last' do
              expect(subject.data['foo'].last).to eql('!mail.bar.gov')
            end
          end

          context 'writing' do
            before { subject.write }

            it 'writes the contents' do
              expect(stubbed_file_contents).to match("// foo\nbar.gov\nbaz.net")
            end
          end
        end
      end
    end
  end
end
