module Mapping
  def to_names
    value['name'].value
  end

  def to_titles
    value['Title'].value
  end
end
