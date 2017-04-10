module PdfHelper
  def zip_folder(folder, zipfile_name)
    input_filenames = Dir.entries("#{folder}/").select { |f| !File.directory? f }
    Zip.continue_on_exists_proc = true
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, folder + '/' + filename)
      end
      # zipfile.get_output_stream('myFile') { |os| os.write 'myFile contains just this' }
    end
  end
end
