class BSON::ObjectId
  def as_json(options = nil)
    to_s
  end
end
