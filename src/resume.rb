require 'prawn'

class Page
  attr_accessor :pdf

  PROFILE_TEXT = "Creative developer who loves to make useful applications " +
        "in a beautiful way. Eleven years in software and web development " +
        "in various forms as well as a bachelors degree in Computer Science. " +
        "Possesses a passion for learning. Communicates well with other " +
        "departments and co-workers such as customer service and designers."
  
  SKILLS = [ ["Ruby", "Regular expressions", "Java"],
             ["JavaScript/JQuery", "CSS", "Sinatra/Rails"],
             ["XSLT", "HTML", "PHP"] ]

  JOB_EXPERIENCE = [
    { position: "IT and Web Development",
      company: "Focus Marketing, Inc / T. M. Transition Services, LLC",
      duration: "7/2012 to present",
      description: [
        "Updated and maintained mymenulab.com and the Storefront sites used to create and sell menus",
        "Used Ruby and Sinatra along with MongoDB to create systems to work in conjunction with the Storefront site.",
        "Created new menu templates in Pageflex Studio."
      ]},
    { position: "Software Development Consultant",
      company: "COCC",
      duration: "4/2011 to 7/2011",
      description: [
        "Developed Java libraries to store financial statements as HTML document.",
        "Managed XSL and XTHML display issues for customer statements and resolved issues quickly.",
        "Assisted support staff in the understanding of the OSI DDS/D3 system."
      ]},
    { position: "Programming Consultant/Custom Developer",
      company: "COWWW Software / Open Solutions, Inc",
      duration: "5/2002 to 5/2009\n12/2009 to 4/2011",
      description: [
        "Utilized regular expressions, XSLT, and XHTML to develop displays for financial statements.",
        "Wrote Java classes to retrieve information from a database for customized marketing displays.",
        "Created XHTML displays for statements and credit cards of dozens of financial institutions including CU*Answers, COCC, Fidelity, and Partners Credit Union for Disney employees."
      ]}
  ]

  def initialize(pdf)
    @pdf         = pdf
    @base_height = @pdf.bounds.height
    @base_width  = @pdf.bounds.width
    @y_position  = @base_height
    @background  = File.join(File.dirname(__FILE__), '../assets/parchment2.jpg')
    @divider     = File.join(File.dirname(__FILE__), '../assets/page-divider.png')
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
    @pdf.text "Elizabeth Day", size: 16, style: :bold
    add_email_address
    add_twitter_handle
  end

  def add_email_address
    @pdf.formatted_text [ { text: "elizabeth.d.day@gmail.com",
                            link: "mailto:elizabeth.d.day@gmail.com",
                            size: 12, color: "0000AA", styles: [:underline] } ]
  end

  def add_twitter_handle
    @pdf.formatted_text [ { text: "@bsunrise",
                            link: "https://twitter.com/bsunrise",
                            size: 12, color: "0000AA", styles: [:underline] } ]
  end

  def add_right_text
    @pdf.bounding_box([(@base_width/2)-30, @y_position], width: @base_width/2) do
      @pdf.move_down 7
      @pdf.font_size 11
      @pdf.text "616.366.6823\n5621 Roosevelt St\nCoopersville, MI 49404",
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
    add_label "Profile"
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      @pdf.text PROFILE_TEXT
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_skills
    add_label "Skills"
    @pdf.bounding_box([120, @y_position + 4],
        width: @base_width - 140, height: 51) do
      @pdf.table(SKILLS, column_widths: [130, 130, 100],
                 cell_style: {borders: [], padding: 2 })
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_experience
    add_label "Experience"
    @pdf.bounding_box([120, @y_position + 4], width: @base_width - 140) do
      JOB_EXPERIENCE.each do |job|
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
      [["#{job[:position]}\n#{job[:company]}", job[:duration]]],
      column_widths: [(@base_width-140) * 0.75, (@base_width-140) * 0.25],
      cell_style: {borders: [], padding: 3})
  end

  def job_duties_table job
    job_duties_table = []
    job[:description].each { |descrip| job_duties_table << [nbsp, "\u2022", descrip] }
    @pdf.make_table(job_duties_table, cell_style: {borders: {}, padding: 2})
  end

  def experience_note
    @pdf.text "* See <u><color rgb='0000AA'><link href='http://www.linkedin.com/in/elizabethdawnday'>" +
      "http://www.linkedin.com/in/elizabethdawnday</link></color></u> " +
      "for a more detailed overview of previous work history ",
      size: 8, inline_format: true
  end

  def add_education
    add_label "Education"
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      @pdf.text "Bachelor of Science in Computer Science"
      @pdf.text "Grand Valley State University - May 2001"
      @pdf.move_down 4
      @pdf.text "Member of Upsilon Pi Epsilon Honor Society"
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_activities
    add_label "Other\nActivities"
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      @pdf.text "Member of GR Web Development Group\nMember of West Michigan Ruby User Group"
      @pdf.text "Crafting and Sewing\nMother"
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_references
    add_label "References"
    @pdf.bounding_box([120, @y_position], width: @base_width - 140) do
      @pdf.text "Submitted upon request"
      adjust_y_position @pdf.bounds.height
    end
  end

  def add_label label
    @pdf.bounding_box([30, @y_position], width: 80) do
      @pdf.text label, style: :bold
    end
  end

  def adjust_y_position adjustment
    @y_position -= adjustment + 7
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
