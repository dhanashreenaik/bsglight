require 'fileutils'

# Load Attachments to Fixtures
def file_path_import(params)
    raise unless params[:model]
    raise unless params[:id]
    raise unless params[:file_name]
    src = File.join(RAILS_ROOT, params[:file_name].to_s)
    dst = File.join(RAILS_ROOT, 'public', 'uploaded_files', RAILS_ENV, params[:model].to_s, params[:id].to_s, 'medium')
		FileUtils.mkdir_p(dst)
    FileUtils.ln_s(src, dst+'/'+params[:file_name].split('/').last, :force => true) unless File.exists?(dst+'/'+params[:file_name].split('/').last)
    return params[:file_name].split('/').last
end
