class Inventory < ApplicationRecord
  belongs_to :inventory_type
  belongs_to :transfer, optional:true
  scope :shod, ->(id) { where(id: id).take }
  validates :branch, presence:true
  validates :description, presence:true
  validates :part_no , presence:true
  validates :inventory_type_id, presence:true
  def self.search(search)
    where("description LIKE ? OR part_no LIKE ? OR branch LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%") 
  end
  
  def self.to_csv(fields = column_names, options = {})
   CSV.generate(options) do |csv|
    csv << column_names
    all.each do |inventory|
      csv << inventory.attributes.values_at(*column_names)
    end
    end
  end

COLUMNS_TO_STRING = ["inventory_type_id"] # and so on

def self.import(file)
  spreadsheet = open_spreadsheet(file)
  header = spreadsheet.row(1)
  (2..spreadsheet.last_row).each do |i|
    row = Hash[[header, spreadsheet.row(i)].transpose]
    row = clean_for row, COLUMNS_TO_STRING
    record = Inventory.find_by(:id => row["id"]) || new
    record.attributes = row.to_hash.slice(*row.to_hash.keys)
    record.save!
  end
end

def self.clean_for row_as_hash, string_columns_array
  row_as_hash.each do |key, value|
    if string_columns_array.include?key
      row_as_hash[key] = value.to_i.to_s
    end
  end
end



def self.open_spreadsheet(file)
  case File.extname(file.original_filename)
  when ".csv" then Roo::CSV.new(file.path)
  when ".xls" then Roo::Excel.new(file.path)
  when ".xlsx" then Roo::Excelx.new(file.path)
  else raise "Unknown file type: #{file.original_filename}"
  end
end
 
  # def self.search_inventory(search)
  #   Inventory.where "concat_ws(' ',description)like ? \
  #   OR concat_ws(' ',part_no)like ? \
  #   OR branch like ?", "#{search}%", "#{search}%", "#{search}%"
  # end
    
end
