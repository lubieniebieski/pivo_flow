module PivoFlow
  module State
    module_function

    def current_branch_name
      Grit::Repo.new(Dir.pwd).head.name
    end

    def story_id_tmp_path
      "#{Dir.pwd}/tmp/.pivo_flow/stories"
    end

    def current_story_id_file_path
      flat_branch_name = current_branch_name.gsub('/', '--')

      File.join(story_id_tmp_path, flat_branch_name)
    end

    def current_story_id
      return nil unless File.exist?(current_story_id_file_path)

      File.read(current_story_id_file_path)
    end
  end
end
