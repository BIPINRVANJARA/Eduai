import React from 'react'

interface Column<T> {
  key: keyof T | string
  header: string
  render?: (item: T) => React.ReactNode
}

interface DataTableProps<T> {
  columns: Column<T>[]
  data: T[]
  isLoading?: boolean
  emptyMessage?: string
}

export default function DataTable<T>({ columns, data, isLoading, emptyMessage = 'No data available' }: DataTableProps<T>) {
  if (isLoading) {
    return (
      <div className="w-full p-8 text-center bg-surface border border-card-border rounded-xl">
        <p className="text-text-secondary">Loading data...</p>
      </div>
    )
  }

  if (data.length === 0) {
    return (
      <div className="w-full p-8 text-center bg-surface border border-card-border rounded-xl">
        <p className="text-text-secondary">{emptyMessage}</p>
      </div>
    )
  }

  return (
    <div className="w-full overflow-x-auto bg-surface border border-card-border rounded-xl">
      <table className="w-full text-left text-sm text-text-secondary">
        <thead className="text-xs text-text-primary uppercase bg-surface-light border-b border-card-border">
          <tr>
            {columns.map((col, idx) => (
              <th key={String(col.key) + idx} className="px-6 py-4 font-medium">
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, rowIndex) => (
            <tr key={rowIndex} className="border-b border-card-border hover:bg-surface-light/50 transition-colors">
              {columns.map((col, colIndex) => (
                <td key={String(col.key) + colIndex} className="px-6 py-4 whitespace-nowrap">
                  {col.render ? col.render(row) : (row as any)[col.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
