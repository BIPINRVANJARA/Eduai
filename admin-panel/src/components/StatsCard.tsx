import React from 'react'

interface StatsCardProps {
  title: string
  value: string | number
  icon: React.ReactNode
  trend?: string
}

export default function StatsCard({ title, value, icon, trend }: StatsCardProps) {
  return (
    <div className="bg-surface p-6 rounded-xl border border-card-border shadow-sm">
      <div className="flex justify-between items-start">
        <div>
          <p className="text-text-secondary text-sm font-medium mb-1">{title}</p>
          <h3 className="text-3xl font-bold text-text-primary">{value}</h3>
          {trend && (
            <p className="text-accent text-sm mt-2 font-medium">{trend}</p>
          )}
        </div>
        <div className="p-3 bg-surface-light rounded-lg text-primary">
          {icon}
        </div>
      </div>
    </div>
  )
}
