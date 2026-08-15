import React, { useState, useRef } from 'react'
import { UploadCloud, X } from 'lucide-react'

interface FileUploaderProps {
  onFileSelect: (file: File | null) => void
  selectedFile: File | null
}

export default function FileUploader({ onFileSelect, selectedFile }: FileUploaderProps) {
  const [isDragging, setIsDragging] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

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
      onFileSelect(e.dataTransfer.files[0])
    }
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      onFileSelect(e.target.files[0])
    }
  }

  return (
    <div className="w-full">
      {!selectedFile ? (
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
          />
          <UploadCloud className="mx-auto h-12 w-12 text-text-secondary mb-4" />
          <h3 className="text-lg font-medium text-text-primary mb-1">Click or drag file to this area to upload</h3>
          <p className="text-text-secondary text-sm">Support for a single or bulk upload. Strictly prohibit from uploading company data or other band files</p>
        </div>
      ) : (
        <div className="bg-surface border border-card-border rounded-xl p-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-primary/10 rounded text-primary">
              <UploadCloud size={20} />
            </div>
            <div>
              <p className="text-text-primary font-medium text-sm">{selectedFile.name}</p>
              <p className="text-text-secondary text-xs">{(selectedFile.size / 1024 / 1024).toFixed(2)} MB</p>
            </div>
          </div>
          <button
            type="button"
            onClick={() => onFileSelect(null)}
            className="text-text-secondary hover:text-error transition-colors p-2"
          >
            <X size={20} />
          </button>
        </div>
      )}
    </div>
  )
}
