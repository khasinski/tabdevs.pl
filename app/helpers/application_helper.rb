module ApplicationHelper
  include Pagy::Method

  def markdown(text)
    return "" if text.blank?
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      link_attributes: { target: "_blank", rel: "noopener noreferrer" }
    )
    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      strikethrough: true
    )
    sanitize(markdown.render(text), tags: %w[p br strong em a code pre ul ol li blockquote])
  end

  def time_ago_in_words_pl(time)
    distance = Time.current - time
    case distance
    when 0..59
      t("time_ago.just_now")
    when 60..3599
      minutes = (distance / 60).to_i
      t("time_ago.minutes", count: minutes, form: pluralize_form(minutes))
    when 3600..86399
      hours = (distance / 3600).to_i
      t("time_ago.hours", count: hours, form: pluralize_form(hours))
    else
      days = (distance / 86400).to_i
      if days == 1
        t("time_ago.yesterday")
      elsif days < 7
        t("time_ago.days", count: days, form: pluralize_form(days))
      else
        time.strftime("%d.%m.%Y")
      end
    end
  end

  def pluralize_form(count)
    return :one if count == 1
    return :few if count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)
    :many
  end

  def pluralize_pl(count, one, few, many)
    form = pluralize_form(count)
    case form
    when :one then one
    when :few then few
    else many
    end
  end

  def pluralize_points(count)
    "#{count} #{pluralize_pl(count, t('views.points.one', count: count).split.last, t('views.points.few', count: count).split.last, t('views.points.many', count: count).split.last)}"
  end

  def pluralize_comments(count)
    return t("views.comments.count_zero") if count == 0
    key = case pluralize_form(count)
          when :one then "views.comments.count_one"
          when :few then "views.comments.count_few"
          else "views.comments.count_many"
          end
    t(key, count: count)
  end
end
