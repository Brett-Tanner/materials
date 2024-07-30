# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfBodyItem, PdfFooter, PdfHeaderItem, PdfList

  BACKGROUND_PATH =
    Rails.root.join('app/assets/pdf_backgrounds/daily_activity.png').to_s
  HEADER_INDENT = 20.mm

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4',
                          page_layout: :portrait) do |pdf|
        apply_defaults(pdf)
        pdf.image BACKGROUND_PATH, at: [0, PAGE_HEIGHT],
                                   height: PAGE_HEIGHT, width: PAGE_WIDTH
        draw_header(pdf)
        add_image(pdf)
        draw_lang_goals(pdf)
        draw_body(pdf)
        draw_footer(pdf:, level: kindy? ? 'Kindergarten' : 'Elementary')
      end
    end
  end

  def draw_header(pdf)
    factory = PdfHeaderItemFactory.new(pdf)

    factory.draw(text: subtype.titleize, y_pos: 280.mm,
                 height: 3.mm, size: FONT_SIZE)
    factory.draw(text: title, y_pos: 275.mm,
                 height: 10.mm, size: HEADING_SIZE)
    factory.draw(text: goal, y_pos: 265.mm,
                 height: 15.mm, size: FONT_SIZE)
    return if warning.blank?

    pdf.bounding_box([HEADER_INDENT, 244.mm],
                     width: 88.mm, height: 8.mm) do
      pdf.text warning, color: RED, overflow: :shrink_to_fit, min_font_size: 0
    end
  end

  def draw_lang_goals(pdf)
    x_position = HEADER_INDENT + 2.mm

    [land_lang_goals, sky_lang_goals, galaxy_lang_goals].each do |goals|
      pdf.bounding_box([x_position, 220.mm], width: 51.mm, height: 11.mm) do
        pdf.text array_to_list(goals),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit,
                 min_font_size: 0
      end
      x_position += 58.mm
    end
  end

  def draw_body(pdf)
    factory = PdfBodyItemFactory.new(pdf)

    factory.draw(text: array_to_list(materials, :number),
                 y_pos: 193.mm, height: 30.mm)
    factory.draw(text: array_to_list(intro, :dot),
                 y_pos: 150.mm, height: 20.mm)
    factory.draw(text: "Did you know? #{interesting_fact}",
                 y_pos: 127.mm, height: 10.mm,
                 indent: 50.mm, width: 138.mm)
    factory.draw(text: array_to_list(instructions, :number),
                 y_pos: 111.mm, height: 40.mm)
    factory.draw(text: array_to_list(large_groups, :dot),
                 y_pos: 71.mm, height: 10.mm)
    factory.draw(text: array_to_list(outro, :dot),
                 y_pos: 53.mm, height: 30.mm)
  end
end
