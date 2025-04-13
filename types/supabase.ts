export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          name: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
        }
      }
      groups: {
        Row: {
          id: string
          name: string
          invite_code: string
          created_by: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          invite_code: string
          created_by: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          invite_code?: string
          created_by?: string
          created_at?: string
          updated_at?: string
        }
      }
      group_members: {
        Row: {
          group_id: string
          user_id: string
          joined_at: string
        }
        Insert: {
          group_id: string
          user_id: string
          joined_at?: string
        }
        Update: {
          group_id?: string
          user_id?: string
          joined_at?: string
        }
      }
      bets: {
        Row: {
          id: string
          group_id: string
          title: string
          description: string | null
          amount: number
          created_by: string
          due_date: string | null
          status: string
          winning_outcome_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          group_id: string
          title: string
          description?: string | null
          amount: number
          created_by: string
          due_date?: string | null
          status?: string
          winning_outcome_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          group_id?: string
          title?: string
          description?: string | null
          amount?: number
          created_by?: string
          due_date?: string | null
          status?: string
          winning_outcome_id?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      bet_participants: {
        Row: {
          bet_id: string
          user_id: string
          outcome_id: string | null
          status: string
          created_at: string
        }
        Insert: {
          bet_id: string
          user_id: string
          outcome_id?: string | null
          status?: string
          created_at?: string
        }
        Update: {
          bet_id?: string
          user_id?: string
          outcome_id?: string | null
          status?: string
          created_at?: string
        }
      }
      bet_outcomes: {
        Row: {
          id: string
          bet_id: string
          description: string
          created_at: string
        }
        Insert: {
          id?: string
          bet_id: string
          description: string
          created_at?: string
        }
        Update: {
          id?: string
          bet_id?: string
          description?: string
          created_at?: string
        }
      }
    }
  }
}