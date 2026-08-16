export interface Profile {
  id: string;
  role: string;
  full_name: string;
  email: string;
  mobile: string;
  institution_id: string;
  department?: string;
  department_id?: string;
  created_at: string;
}

export interface Department {
  id: string;
  institution_id: string;
  name: string;
  code: string;
  hod_name: string;
  hod_email: string;
  hod_mobile: string;
  admin_password?: string;
  status: 'active' | 'inactive';
  student_count?: number;
  created_at: string;
}

export interface Student {
  id: string;
  profile_id: string;
  enrollment_no: string;
  full_name: string;
  email: string;
  mobile: string;
  parent_email: string;
  parent_mobile: string;
  department: string;
  semester: string;
  division: string;
  birthdate: string;
  institution_id: string;
  overall_attendance: number;
  created_at: string;
}

export interface Parent {
  id: string;
  profile_id: string;
  email: string;
  full_name: string;
  mobile: string;
  created_at: string;
}

export interface Document {
  id: string;
  institution_id: string;
  title: string;
  description: string;
  category: string;
  department: string;
  semester: string;
  division: string;
  subject_name: string;
  tags?: string[];
  content_summary?: string;
  file_url: string;
  file_name: string;
  file_size: number;
  uploaded_by: string;
  created_at: string;
}

export interface Alert {
  id: string;
  title: string;
  message: string;
  category: 'attendance' | 'marks' | 'fees' | 'timetable' | 'holiday' | 'general' | 'emergency';
  department: string;
  semester: string;
  priority: 'normal' | 'high' | 'urgent';
  created_by?: string;
  created_at: string;
}
