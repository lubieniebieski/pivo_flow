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
        expect{pivotal.fetch_stories}.to raise_error(PivoFlow::Errors::UnsuccessfulPivotalConnection)
      end
    end

    it "when api-token is incorrect (unauthorized)" do
      VCR.use_cassette(:pivotal_fetch_project_unauthorized) do
        expect{pivotal.fetch_stories}.to raise_error(PivoFlow::Errors::UnsuccessfulPivotalConnection)
      end
    end

  end

  describe "methods" do

    before(:each) do
      stub_pivotal_project
      pivotal.run
    end

    it "does not call pivotal upon run" do
      pivotal.options[:project].should be_nil
    end

    it "calls pivotal when necessary" do
      pivotal.should_receive(:ensure_project).once
      pivotal.fetch_stories
    end

    it "does not call pivotal twice" do
      PivotalTracker::Project.should_receive(:find).once
      2.times { pivotal.fetch_stories }
    end

    it "user_stories takes only stories owned by current user" do
      pivotal.user_stories.should eq [@story_feature]
    end

    it "unasigned_stories takes only stories with no user" do
      pivotal.unasigned_stories.should eq [@story_unassigned]
    end

    it "show_stories should display stories on output" do
      pivotal.should_receive(:list_stories_to_output)
      pivotal.show_stories
    end

    describe "story_string" do

      it "includes story id" do
        pivotal.story_string(@story_feature).should match(/[##{@story_feature.id}]/)      end

      it "includes story name" do
        pivotal.story_string(@story_feature).should match(/#{@story_feature.name}/)
      end

    end

    describe "deliver" do

      it "list only the stories with 'finished' status" do
        pivotal.should_receive(:user_name).and_return(@story_finished.owned_by)
        @project.stub_chain(:stories, :all).and_return([@story_finished])
        pivotal.should_receive(:list_stories_to_output).with([@story_finished], "deliver")
        pivotal.deliver
      end

    end

    describe "list_stories_to_output" do

      it "returns 1 if stories are nil" do
        pivotal.list_stories_to_output(nil).should eq 1
      end

      it "returns 1 if stories are []" do
        pivotal.list_stories_to_output([]).should eq 1
      end

    end

    describe "show_story" do

      after(:each) do
        pivotal.stub(:show_stories)
        # pivotal.stub(:update_story)
        pivotal.stub(:show_info)

        pivotal.show_story 1
      end

      describe "if story's state is 'finished'" do

        before(:each) do
          @story_feature.stub(:current_state).and_return("finished")
          pivotal.stub(:ask_question).and_return("y")
        end

        it "ask for deliver the story" do
          pivotal.should_receive(:ask_question).with(/deliver/)
        end

        it "updates story on pivotal with 'delivered' status" do
          @story_feature.should_receive(:update).with({ owned_by: @story_feature.owned_by, current_state: :delivered })
        end

      end


      it "shows info about the story" do
        pivotal.stub(:ask_question).and_return("no")
        pivotal.should_receive(:show_info)
      end

      it "updates the story if user response is 'yes'" do
        pivotal.stub(:ask_question).and_return("yes")
        pivotal.should_receive(:update_story)
      end

      it "show stories if user response is 'no'" do
        pivotal.stub(:ask_question).and_return("no")
        pivotal.should_receive(:show_stories)
      end
    end

    describe "start_story" do

      before(:each) do
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
      labels: "first,second"
    )

    @story_feature.stub_chain(:update).and_return(mock(errors: []))
    @story_unassigned = PivotalTracker::Story.new(owned_by: nil, name: "test", current_state: "started")
    @story_rejected = PivotalTracker::Story.new(current_state: "rejected", owned_by: "Mark Marco", name: "test_rejected")
    @story_finished = PivotalTracker::Story.new(current_state: "finished", owned_by: "Mark Marco", name: "finished")
    @project.stub_chain(:stories, :all).and_return([@story_feature, @story_unassigned, @story_rejected, @story_finished])
    PivotalTracker::Project.stub(:find).and_return(@project)
  end
end
