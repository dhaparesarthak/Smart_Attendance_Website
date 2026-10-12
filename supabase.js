// =============================================
// supabase.js — Shared Supabase Client
// Imported by every HTML page via <script> tag
// =============================================

import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm'

// Replace these with your actual Supabase project values
// Found at: https://supabase.com → Your Project → Settings → API
const SUPABASE_URL = 'https://jhoazibsyyuhdodrzpcs.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impob2F6aWJzeXl1aGRvZHJ6cGNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NDM4ODIsImV4cCI6MjEwNzIxOTg4Mn0.qrW9qKDCKLpyM0xZ2YAi07cW1w8efTn_9SvY4thglXY'

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)


// =============================================
// AUTH HELPERS
// =============================================

// Get currently logged in user from Supabase auth
export async function getAuthUser() {
  const { data: { user } } = await supabase.auth.getUser()
  return user
}

// Get full user profile (name, role, prn) from users table
export async function getUserProfile(userId) {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .single()
  if (error) return null
  return data
}

// Redirect to login if not authenticated
export async function requireAuth() {
  const user = await getAuthUser()
  if (!user) {
    location.href = 'login.html'
    return null
  }
  return user
}

// Redirect to login if not authenticated or wrong role
// usage: requireRole('teacher')
export async function requireRole(role) {
  const user = await requireAuth()
  if (!user) return null
  const profile = await getUserProfile(user.id)
  if (!profile) {
    location.href = 'login.html'
    return null
  }
  if (profile.role !== role) {
    location.href = 'login.html'
    return null
  }
  return profile
}

// Logout
export async function logout() {
  await supabase.auth.signOut()
  location.href = 'login.html'
}
