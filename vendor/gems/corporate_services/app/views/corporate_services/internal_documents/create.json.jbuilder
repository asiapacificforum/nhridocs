json.files do
  json.partial! 'files', :locals => {:internal_documents => @internal_documents}
end