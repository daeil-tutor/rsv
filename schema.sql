-- =============================================
-- RSV 예방 캠페인 — baby_names 테이블 + baby_names_kst 뷰
-- Supabase SQL Editor에서 위에서 아래로 한 번에 실행
--
-- 배포된 프로젝트는 컬럼명이 nickname 이 아니라 name 인 경우가 많습니다.
-- REST 클라이언트는 JSON 키 "name" 으로 INSERT 해야 합니다 (index.html 반영됨).
-- =============================================

CREATE TABLE IF NOT EXISTS baby_names (
  id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  name        text        NOT NULL,
  created_at  timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE baby_names DROP CONSTRAINT IF EXISTS name_length;
ALTER TABLE baby_names DROP CONSTRAINT IF EXISTS nickname_length;
ALTER TABLE baby_names
  ADD CONSTRAINT name_length CHECK (char_length(name) BETWEEN 1 AND 20);

CREATE INDEX IF NOT EXISTS idx_baby_names_created_at ON baby_names (created_at DESC);

ALTER TABLE baby_names ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can insert" ON baby_names;
DROP POLICY IF EXISTS "Service role can select" ON baby_names;

CREATE POLICY "Anyone can insert"
  ON baby_names
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Service role can select"
  ON baby_names
  FOR SELECT
  TO service_role
  USING (true);

-- 기존 뷰 컬럼을 바꿀 때는 REPLACE 만으로는 불가 → 먼저 삭제 후 생성
DROP VIEW IF EXISTS baby_names_kst;

CREATE VIEW baby_names_kst AS
SELECT
  id,
  name,
  timezone('Asia/Seoul', created_at) AS created_at_kst
FROM baby_names;

-- 이미 nickname 컬럼만 있는 테이블이면 한 번만 실행 (에러 나면 스킵)
-- ALTER TABLE baby_names RENAME COLUMN nickname TO name;
