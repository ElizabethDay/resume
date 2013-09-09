require 'prawn'
require 'i18n'

class Page
  attr_accessor :pdf

  def initialize(pdf)
    @pdf = pdf
    initialize_measurements
    initialize_images
    initialize_i18n
  end

  def initialize_measurements
    @base_height = @pdf.bounds.height
    @base_width  = @pdf.bounds.width
    @y_position  = @base_height
  end

  def initialize_images
    @background  = File.join(File.dirname(__FILE__), '../assets/parchment2.jpg')
    @divider     = File.join(File.dirname(__FILE__), '../assets/page-divider.png')
  end

  def initialize_i18n
    I18n.load_path = Dir['config/locales/*.yml']
    I18n.backend.load_translations
  end

  def add_background
    @pdf.canvas do
      @pdf.image @background, at: [0, @pdf.bounds.height],
        width: @pdf.bounds.width, height: @pdf.bounds.height
    end
  end

  def add_header
    add_header_text
    add_divider
    @pdf.font_size 11
  end

  def add_header_text
    add_left_text_box
    add_right_text
  end

  def add_left_text_box
    @pdf.bounding_box([30, @y_position], width: (@base_width/2)-5) do
      @pdf.move_down 5
      add_name_text
    end
  end

  def add_name_text
    @pdf.text I18n.t(:name), size: 16, style: :bold
    add_email_address
    add_twitter_handle
  end

  def add_email_address
    @pdf.formatted_text [ { text: I18n.t(:email),
                            link: "mailto:#{I18n.t(:email)}",
                            size: 12, color: "0000AA", styles: [:underline] } ]
  end

  def add_twitter_handle
    @pdf.formatted_text [ { text: "@#{I18n.t(:twitter_handle)}",
                            link: "https://twitter.com/#{I18n.t(:twitter_handle)}",
                            size: 12, color: "0000AA", styles: [:underline] } ]
  end

  def add_right_text
    @pdf.bounding_box([(@base_width/2)-30, @y_position], width: @base_width/2) do
      @pdf.move_down 7
      @pdf.font_size 11
      @pdf.text "#{I18n.t(:phone_no)}\n#{I18n.t(:street_addr)}\n#{I18n.t(:city_state_zip)}",
        align: :right
      adjust_y_position @pdf.bounds.height + 2
    end
  end

  def add_divider
    @pdf.bounding_box([0, @y_position], width: @base_width, height: 12) do
      @pdf.image @divider, height: 12, position: :center
      adjust_y_position @pdf.bounds.height + 2
    end
  end

  def add_profile
    add_label I18n.t :profile, scope: [:label]
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      @pdf.text I18n.t(:profile)
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_skills
    add_label I18n.t :skills, scope: [:label]
    @pdf.bounding_box([120, @y_position + 4], width: @base_width - 140, height: 51) do
      @pdf.table(I18n.t(:skills), column_widths: [130, 130, 100],
                 cell_style: {borders: [], padding: 2 })
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_experience
    add_label I18n.t :experience, scope: [:label]
    @pdf.bounding_box([120, @y_position + 4], width: @base_width - 140) do
      I18n.t(:job_experience).each do |job|
        create_work_experience_table job_name_table(job), job_duties_table(job)
      end
      experience_note
      adjust_y_position @pdf.bounds.height
    end
  end

  def create_work_experience_table name_table, duties_table
    @pdf.table([ [name_table], [duties_table] ], cell_style: {borders: []})
    @pdf.move_down 5
  end

  def job_name_table job
    @pdf.make_table(
      [["#{job['position']}\n#{job['company']}", job['duration']]],
      column_widths: [(@base_width-140) * 0.75, (@base_width-140) * 0.25],
      cell_style: {borders: [], padding: 3})
  end

  def job_duties_table job
    job_duties_table = []
    job["description"].each { |descrip| job_duties_table << [nbsp, "\u2022", descrip] }
    @pdf.make_table(job_duties_table, cell_style: {borders: {}, padding: 2})
  end

  def experience_note
    @pdf.text I18n.t(:experience_note), size: 8, inline_format: true
  end

  def add_education
    add_label I18n.t :education, scope: [:label]
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      @pdf.text I18n.t(:college_degree)
      @pdf.text "#{I18n.t(:university)} - #{I18n.t(:graduation_date)}"
      @pdf.move_down 4
      @pdf.text I18n.t(:honors)
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_activities
    add_label I18n.t :activities, scope: [:label]
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      I18n.t(:activities).each { |activity| @pdf.text activity }
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_references
    add_label I18n.t :references, scope: [:label]
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      @pdf.text I18n.t(:references)
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_label label
    @pdf.bounding_box([30, @y_position], width: 80) do
      @pdf.text label, style: :bold
    end
  end

  def adjust_y_position adjustment
    @y_position -= adjustment + 8
  end

  def nbsp
    Prawn::Text::NBSP
  end
end

Prawn::Document.generate('ElizabethDay.pdf') do |pdf|
  page = Page.new(pdf)

  page.add_background
  page.add_header
  page.add_profile
  page.add_skills
  page.add_experience
  page.add_education
  page.add_activities
  page.add_references
end
