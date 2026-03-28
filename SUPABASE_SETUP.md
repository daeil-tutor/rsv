# Supabase 셋업 가이드

RSV 예방 캠페인 — 유저가 입력한 **태명** 데이터를 Supabase에 저장하는 가이드입니다.

---

## 1. Supabase 프로젝트 생성

1. [https://supabase.com](https://supabase.com) 접속 후 로그인
2. **New Project** 클릭
3. 프로젝트 이름, 비밀번호(DB 비밀번호), 리전(Northeast Asia – Seoul 권장) 설정
4. **Create new project** 클릭 → 약 1~2분 대기

---

## 2. 테이블 생성 (SQL)

Supabase 대시보드 좌측 메뉴에서 **SQL Editor** 진입 후 아래 SQL을 실행하세요.

```sql
-- 태명 입력 데이터 테이블
CREATE TABLE baby_names (
  id          uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  nickname    text        NOT NULL,                          -- 유저가 입력한 태명
  created_at  timestamptz DEFAULT now() NOT NULL             -- 입력 시각 (UTC)
);

-- 입력값 길이 제한 (1~20자)
ALTER TABLE baby_names
  ADD CONSTRAINT nickname_length CHECK (char_length(nickname) BETWEEN 1 AND 20);

-- 인덱스: 최신순 조회 최적화
CREATE INDEX idx_baby_names_created_at ON baby_names (created_at DESC);
```

### 컬럼 설명

| 컬럼         | 타입          | 설명                        |
|------------|-------------|-----------------------------|
| `id`       | uuid (PK)   | 자동 생성 고유 식별자         |
| `nickname` | text        | 유저가 입력한 태명 (1–20자)   |
| `created_at` | timestamptz | 입력 시각 (자동 기록)        |

---

## 3. Row Level Security (RLS) 설정

```sql
-- RLS 활성화
ALTER TABLE baby_names ENABLE ROW LEVEL SECURITY;

-- 누구나 INSERT 가능 (익명 포함)
CREATE POLICY "Anyone can insert"
  ON baby_names
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- 조회는 인증된 사용자(서비스 롤)만 가능
CREATE POLICY "Service role can select"
  ON baby_names
  FOR SELECT
  TO service_role
  USING (true);
```

> **포인트**: 일반 사용자는 쓰기만 가능하고, 데이터 조회는 서비스 롤 키를 가진 관리자만 가능합니다.

---

## 4. API 키 확인

Supabase 대시보드 → **Project Settings** → **API** 탭에서 아래 두 값을 복사하세요.

| 항목 | 설명 |
|---|---|
| **Project URL** | `https://xxxxxxxxxxxx.supabase.co` |
| **anon / public key** | 클라이언트(브라우저)에서 사용할 키 |

---

## 5. index.html에 Supabase 연동

`index.html`의 `</body>` 직전에 아래 스크립트를 추가하세요.

```html
<script type="module">
  import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm'

  const SUPABASE_URL = 'YOUR_SUPABASE_URL'       // 4단계에서 복사한 URL
  const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY'      // 4단계에서 복사한 anon key

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

  const input = document.querySelector('.input-field')

  input.addEventListener('keydown', async (e) => {
    if (e.key !== 'Enter') return
    const nickname = input.value.trim()
    if (!nickname) return

    const { error } = await supabase
      .from('baby_names')
      .insert({ nickname })

    if (error) {
      console.error('저장 실패:', error.message)
      return
    }

    console.log('저장 완료:', nickname)
    // TODO: 다음 화면으로 이동 또는 완료 메시지 표시
  })
</script>
```

---

## 6. 저장 데이터 확인

Supabase 대시보드 → **Table Editor** → `baby_names` 테이블에서 실시간으로 저장된 태명 목록을 확인할 수 있습니다.

```sql
-- 최신순으로 전체 조회
SELECT * FROM baby_names ORDER BY created_at DESC;
```

---

## 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] SQL Editor에서 테이블 생성 실행
- [ ] RLS 정책 적용
- [ ] `index.html`에 URL / anon key 입력
- [ ] 테스트 입력 후 Table Editor에서 데이터 확인
