/*
  # Initial Schema Setup for Betting App

  1. Tables
    - profiles
      - Stores user profile information
    - groups
      - Stores betting groups
    - group_members
      - Links users to groups
    - bets
      - Stores bet information
    - bet_participants
      - Links users to bets
    - bet_outcomes
      - Stores possible outcomes for bets

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated access
*/

-- Create profiles table
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create groups table
CREATE TABLE groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  invite_code text UNIQUE NOT NULL,
  created_by uuid REFERENCES profiles(id) NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create group_members table
CREATE TABLE group_members (
  group_id uuid REFERENCES groups(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (group_id, user_id)
);

-- Create bets table
CREATE TABLE bets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid REFERENCES groups(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  amount decimal NOT NULL,
  created_by uuid REFERENCES profiles(id) NOT NULL,
  due_date timestamptz,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'resolved')),
  winning_outcome_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create bet_participants table
CREATE TABLE bet_participants (
  bet_id uuid REFERENCES bets(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  outcome_id uuid,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (bet_id, user_id)
);

-- Create bet_outcomes table
CREATE TABLE bet_outcomes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bet_id uuid REFERENCES bets(id) ON DELETE CASCADE,
  description text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE bet_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE bet_outcomes ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can read their own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Groups policies
CREATE POLICY "Members can read groups they belong to"
  ON groups FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_id = groups.id
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Any user can create a group"
  ON groups FOR INSERT
  TO authenticated
  WITH CHECK (created_by = auth.uid());

-- Group members policies
CREATE POLICY "Members can read group membership"
  ON group_members FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join groups"
  ON group_members FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Bets policies
CREATE POLICY "Group members can read bets"
  ON bets FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_id = bets.group_id
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Group members can create bets"
  ON bets FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_id = NEW.group_id
      AND user_id = auth.uid()
    )
  );

-- Bet participants policies
CREATE POLICY "Group members can read bet participants"
  ON bet_participants FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bets b
      JOIN group_members gm ON b.group_id = gm.group_id
      WHERE b.id = bet_participants.bet_id
      AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can participate in bets"
  ON bet_participants FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Bet outcomes policies
CREATE POLICY "Group members can read bet outcomes"
  ON bet_outcomes FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM bets b
      JOIN group_members gm ON b.group_id = gm.group_id
      WHERE b.id = bet_outcomes.bet_id
      AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "Bet creators can create outcomes"
  ON bet_outcomes FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bets
      WHERE id = NEW.bet_id
      AND created_by = auth.uid()
    )
  );