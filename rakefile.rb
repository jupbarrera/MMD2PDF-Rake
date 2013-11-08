# Set the default task.
task :default => [:mmd2tex, :tex2pdf, :tex2pdfclean]

# Basic settings.
FileName  = 'main.tex'
PDFReader = 'evince'

# Compile main LaTeX file to a PDF.
task :tex2pdf do
  FileList['*.tex'].each do |filename|
    TeX2PDF.compile(filename)
  end
end

# Clean up all temporary pdfLaTeX files.
task :tex2pdfclean do
  clean(TeX2PDF.cleanup)
end

# Compile all MultiMarkdown files to TeX.
task :mmd2tex do 
  FileList['*.mmd'].each do |filename|
    MMD2TeX.compile(filename)
  end
end

# Clean up all temporary TeX files.
task :mmd2texclean do
  clean(MMD2TeX.cleanup)
end

# Open Acrobat Reader with PDF.
task :openreader do
  %x{start "" "#{PDFReader}" -reuse-instance -restrict "#{FileName.ext('pdf')}"} if File.exist?(FileName.ext('pdf'))
end

# Combines all clean tasks
task :clean => [:tex2pdfclean, :mmd2texclean]

# Utility: clean files if any are given.
def clean(list)
  rm_rf(list) unless list.empty?
end

# Utility: handle TeX2PDT compilation.
module TeX2PDF

  # Compile several times with pdfLaTeX (for bibTex).
  def self.compile(filename)
    puts "pdfLaTeX #{filename}"
    puts %x{pdflatex #{filename}}
    puts %x{bibtex   #{filename}}
    puts %x{pdflatex #{filename}}
    puts %x{pdflatex #{filename}}
  end
  
  # List all of pdfLaTeX's temporary files.
  def self.cleanup
    FileList[*%w{*.log *.dvi *.aux *.bbl *.blg *.brf *.out *.glo *.toc}]
  end
end

# Utility: handle MMD2TeX compilation.
module MMD2TeX

  # Compiles a MultiMarkdown file to a TeX file.
  def self.compile(filename)
    puts "MultiMarkdown: mmd2tex #{filename}"
    puts %x{mmd2tex #{filename}}
  end
  
  # List all TeX files that have an associated MMD file.
  def self.cleanup
    FileList['*.mmd'].ext('tex')
  end
end
