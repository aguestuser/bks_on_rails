module SortableHelper
  
  def sort_if_sortable(cell)
    if cell.sortable
      sortable( cell.val, cell.sort_key )
    else
      cell.val
    end
  end

  def sortable(column, title=nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, { sort: column, direction: direction, filter: @filter}, {:class => css_class}
  end

  def grid_sortable(column, title)
    css_class = column == @sort_key ? "current #{@sort_dir}" : nil
    direction = column == @sort_key && @sort_dir == "asc" ? "desc" : "asc"
    link_to title, { sort: column, direction: direction, filter: @filter}, {:class => css_class}
  end
end