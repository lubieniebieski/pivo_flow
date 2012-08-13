require "spec_helper"

describe PivoFlow::Pivotal do

  let(:pivotal) { PivoFlow::Pivotal.new }

  before do
    stub_git_config
    PivoFlow::Pivotal.any_instance.stub(:puts)
    stub_base_methods(PivoFlow::Pivotal)
  end

  describe "raises exception" do
    it "when project id is incorrect" do
      VCR.use_cassette(:pivotal_fetch_project_not_found) do
        expect{pivotal.run}.to raise_error(PivoFlow::Errors::UnsuccessfulPivotalConnection)
      end
    end

    it "when api-token is incorrect (unauthorized)" do
      VCR.use_cassette(:pivotal_fetch_project_unauthorized) do
        expect{pivotal.run}.to raise_error(PivoFlow::Errors::UnsuccessfulPivotalConnection)
      end
    end

  end

  describe "methods" do

    before(:each) do
      stub_pivotal_project
      pivotal.run
    end

    it "fetches with correct id" do
      pivotal.options[:project].id.should eq 123456
    end

    it "user_stories takes only stories owned by current user" do
      pivotal.user_stories.should eq [@story_feature]
    end

    it "unasigned_stories takes only stories with no user" do
      pivotal.unasigned_stories.should eq [@story_unassigned]
    end

    describe "start_story" do
      before(:each) do
        @story_feature.stub_chain(:update, :errors, :count).and_return(0)
        @story_feature.should_receive(:update).with({ current_state: :started, owned_by: pivotal.user_name })
      end

      it "updates pivotal tracker" do
        pivotal.start_story(@story_feature.id)
      end

      it "returns true on success" do
        pivotal.start_story(@story_feature.id).should be_true
      end

    end

    it "show_info returns 1 if there is no story" do
      @project.stub_chain(:stories, :all).and_return([])
      expect(pivotal.show_info).to eq 1
    end

    describe "current_story" do
      before(:each) do
        @users_story1 = PivotalTracker::Story.new(owned_by: pivotal.user_name, current_state: "started")
        @users_story2 = PivotalTracker::Story.new(owned_by: pivotal.user_name, current_state: "started")
        @users_story3 = PivotalTracker::Story.new(owned_by: pivotal.user_name, current_state: "unstarted")
        @users_story4 = PivotalTracker::Story.new(owned_by: pivotal.user_name, current_state: "unstarted")
      end


      it "is the first of user's started stories" do
        @project.stub_chain(:stories, :all).and_return([@users_story1, @users_story2])

        pivotal.current_story.should eq @users_story1
      end

      it "is the first of user's stories if he has no started stories" do
        @project.stub_chain(:stories, :all).and_return([@users_story3, @users_story4])

        pivotal.current_story.should eq @users_story3
      end

      it "is nil if there is no stories assigned to user" do
        @project.stub_chain(:stories, :all).and_return([])
        pivotal.current_story.should be_nil
      end

    end

  end

end

def stub_pivotal_project
  @project = PivotalTracker::Project.new(id: 123456, name: "testproject")
  @story_feature = PivotalTracker::Story.new(
    id: 1,
    url: "http://www.pivotaltracker.com/story/show/1",
    created_at: DateTime.now,
    project_id: 123456,
    name: "story no 1",
    description: "story description",
    story_type: "feature",
    estimate: 3,
    current_state: "started",
    requested_by: "Paul Newman",
    owned_by: "Adam Newman",
    labels: "first,second")
  @story_unassigned = PivotalTracker::Story.new(owned_by: nil)
  @project.stub_chain(:stories, :all).and_return([@story_feature, @story_unassigned])
  PivotalTracker::Project.stub(:find).and_return(@project)
end
