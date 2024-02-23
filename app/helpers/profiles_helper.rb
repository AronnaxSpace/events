module ProfilesHelper
  def avatar_size_classes(size = :sm)
    sizes = {
      sm: "w-5 h-5",
      md: "w-10 h-10",
      lg: "w-20 h-20"
    }

    sizes[size] || sizes[:md]
  end
end
