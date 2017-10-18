RSpec.describe 'Gman bin' do
  let(:domain) { 'whitehouse.gov' }
  let(:args) { [domain] }
  let(:command) { 'gman' }
  let(:bin_path) do
    File.expand_path "../../bin/#{command}", File.dirname(__FILE__)
  end
  let(:response_parts) { Open3.capture2e('bundle', 'exec', bin_path, *args) }
  let(:output) { response_parts[0] }
  let(:status) { response_parts[1] }
  let(:exit_code) { status.exitstatus }

  context 'a valid domain' do
    it 'parses the domain' do
      expect(output).to match('Domain  : whitehouse.gov')
    end

    it "knows it's valid" do
      expect(output).to match('Valid government domain')
      expect(exit_code).to eql(0)
    end

    it 'knows the type' do
      expect(output).to match('federal')
    end

    it 'knows the agency' do
      expect(output).to match('Executive Office of the President')
    end

    it 'knows the country' do
      expect(output).to match('United States')
    end

    it 'knows the city' do
      expect(output).to match('Washington')
    end

    it 'knows the state' do
      expect(output).to match('DC')
    end

    it 'colors by default' do
      expect(output).to match(/\e\[32m/)
    end

    context 'with colorization disabled' do
      let(:args) { [domain, '--no-color'] }

      it "doesn't color" do
        expect(output).to_not match(/\e\[32m/)
      end
    end
  end

  context 'with no args' do
    let(:args) { [] }

    it 'displays the help text' do
      expect(output).to match('USAGE')
    end
  end

  context 'an invalid domain' do
    let(:domain) { 'foo.invalid' }

    it 'knows the domain is invalid' do
      expect(output).to match('Invalid domain')
      expect(exit_code).to eql(1)
    end
  end

  context 'a non-government domain' do
    let(:domain) { 'github.com' }

    it "knows it's not a government domain" do
      expect(output).to match('Not a government domain')
      expect(exit_code).to eql(1)
    end
  end

  context 'filtering' do
    let(:command) { 'gman_filter' }
    let(:txt_path) do
      File.expand_path '../fixtures/obama.txt', File.dirname(__FILE__)
    end
    let(:args) { [txt_path] }

    it 'returns only government domains' do
      expected = <<-EXPECTED
mr.senator@obama.senate.gov
president@whitehouse.gov
commander.in.chief@us.army.mil
      EXPECTED

      expect(output).to eql(expected)
    end
  end
end
