require 'spec_helper'

describe PivoFlow::State do
  describe '#current_story_id_file_path' do
    it 'should return a path to a branch-based file name' do
      with_branch_name 'cool-branch'

      expect(PivoFlow::State.current_story_id_file_path).to eq(
        "#{Dir.pwd}/tmp/.pivo_flow/stories/cool-branch"
      )
    end

    it 'should deal with slashes in the branch name' do
      with_branch_name 'feature/my-cool-feature/a-thing'

      expect(PivoFlow::State.current_story_id_file_path).to eq(
        "#{Dir.pwd}/tmp/.pivo_flow/stories/feature--my-cool-feature--a-thing"
      )
    end

    def with_branch_name(name)
      allow(PivoFlow::State).to receive(:current_branch_name) { name }
    end
  end

  describe '#current_story_id' do
    let(:tmp_file) { "#{Dir.pwd}/tmp/.pivo_flow/stories/cool-branch" }

    before do
      allow(PivoFlow::State).to receive(:current_branch_name) { 'cool-branch' }

      FileUtils.mkdir_p(PivoFlow::State.story_id_tmp_path)
      File.write(tmp_file, '123456')
    end

    after { FileUtils.remove_file(tmp_file) }

    it 'should read it from the tmp file' do
      expect(PivoFlow::State.current_story_id).to eq('123456')
    end

    it "should return nil if there's no file for it yet" do
      allow(PivoFlow::State).to receive(:current_branch_name) { 'different' }

      expect(PivoFlow::State.current_story_id).to be_nil
    end
  end
end
