import React, { useState, useRef } from 'react'
import { UploadCloud, X, FileText, Plus } from 'lucide-react'

interface FileUploaderProps {
  onFileSelect?: (file: File | null) => void
  selectedFile?: File | null
  onFilesSelect?: (files: File[]) => void
  selectedFiles?: File[]
  multiple?: boolean
}

export default function FileUploader({ 
  onFileSelect, 
  selectedFile,
  onFilesSelect,
  selectedFiles = [],
  multiple = false
}: FileUploaderProps) {
  const [isDragging, setIsDragging] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const activeFiles = multiple 
    ? selectedFiles 
    : (selectedFile ? [selectedFile] : [])

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      const dropped = Array.from(e.dataTransfer.files)
      if (multiple && onFilesSelect) {
        onFilesSelect([...selectedFiles, ...dropped])
      } else if (onFileSelect) {
        onFileSelect(dropped[0])
      }
    }
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const picked = Array.from(e.target.files)
      if (multiple && onFilesSelect) {
        onFilesSelect([...selectedFiles, ...picked])
      } else if (onFileSelect) {
        onFileSelect(picked[0])
      }
    }
    if (fileInputRef.current) fileInputRef.current.value = ''
  }

  const handleRemoveSingle = (indexToRemove: number) => {
    if (multiple && onFilesSelect) {
      onFilesSelect(selectedFiles.filter((_, i) => i !== indexToRemove))
    } else if (onFileSelect) {
      onFileSelect(null)
    }
  }

  return (
    <div className="w-full space-y-3">
      {activeFiles.length === 0 ? (
        <div
          className={`border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors ${
            isDragging ? 'border-primary bg-primary/5' : 'border-card-border hover:border-text-secondary bg-surface'
          }`}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={() => fileInputRef.current?.click()}
        >
          <input
            type="file"
            className="hidden"
            ref={fileInputRef}
            onChange={handleFileChange}
            multiple={multiple}
          />
          <UploadCloud className="mx-auto h-12 w-12 text-text-secondary mb-4" />
          <h3 className="text-lg font-medium text-text-primary mb-1">
            {multiple ? 'Click or drag documents to upload (Multiple supported)' : 'Click or drag file to this area to upload'}
          </h3>
          <p className="text-text-secondary text-sm">
            Support for PDFs, Word docs, Excel spreadsheets, Lab Manuals, and Timetables
          </p>
        </div>
      ) : (
        <div className="space-y-2">
          {activeFiles.map((file, idx) => (
            <div key={idx} className="bg-surface border border-card-border rounded-xl p-3 flex items-center justify-between shadow-sm">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-primary/10 rounded-lg text-primary">
                  <FileText size={18} />
                </div>
                <div>
                  <p className="text-text-primary font-medium text-sm truncate max-w-sm">{file.name}</p>
                  <p className="text-text-secondary text-xs">{(file.size / 1024).toFixed(1)} KB</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => handleRemoveSingle(idx)}
                className="text-text-secondary hover:text-error transition-colors p-1.5 rounded-lg"
              >
                <X size={18} />
              </button>
            </div>
          ))}

          {multiple && (
            <div className="flex justify-end pt-1">
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="text-xs text-primary hover:underline font-bold flex items-center gap-1 cursor-pointer"
              >
                <Plus size={14} /> Add Another Document
              </button>
              <input
                type="file"
                className="hidden"
                ref={fileInputRef}
                onChange={handleFileChange}
                multiple
              />
            </div>
          )}
        </div>
      )}
    </div>
  )
}
