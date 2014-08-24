module TableHelper

  def link_if_linkable cell
    cell[:href] ? link_to(cell[:val], cell[:href]) : cell[:val]
  end

  def sort_if_sortable header 
    header[:sort_key] ? sortable(header[:sort_key], header[:val]) : header[:val]
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