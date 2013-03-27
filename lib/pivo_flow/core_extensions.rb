class String

  def fix_encoding
    self.encode!('UTF-8', 'US-ASCII', invalid: :replace, replace: "")
  end

end
