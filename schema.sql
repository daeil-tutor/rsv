-- =============================================
-- RSV 예방 캠페인 — 태명 입력 데이터 테이블
-- =============================================

-- 1. 테이블 생성
CREATE TABLE baby_names (
  id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  nickname    text        NOT NULL,
  created_at  timestamptz DEFAULT now() NOT NULL
);

-- 2. 입력값 길이 제한 (1~20자)
ALTER TABLE baby_names
  ADD CONSTRAINT nickname_length CHECK (char_length(nickname) BETWEEN 1 AND 20);

-- 3. 최신순 조회 인덱스
CREATE INDEX idx_baby_names_created_at ON baby_names (created_at DESC);

-- =============================================
-- Row Level Security (RLS)
-- =============================================

-- 4. RLS 활성화
ALTER TABLE baby_names ENABLE ROW LEVEL SECURITY;

-- 5. 익명 유저 — INSERT만 허용
CREATE POLICY "Anyone can insert"
  ON baby_names
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- 6. 서비스 롤 — SELECT 허용 (관리자 조회용)
CREATE POLICY "Service role can select"
  ON baby_names
  FOR SELECT
  TO service_role
  USING (true);
