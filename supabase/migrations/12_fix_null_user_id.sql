-- ============================================
-- Fix NULL user_id dan sync ke user baru
-- ============================================

-- 1. Cek dulu tiket yang user_id-nya NULL
SELECT id, ticket_no, title, user_id
FROM tickets
WHERE user_id IS NULL;

-- 2. Buat user dummy dulu kalau belum ada
INSERT INTO users (id, email, name, role)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'system@eticketing.com',
  'System User',
  'admin'
)
ON CONFLICT (id) DO NOTHING;

-- 3. Update tiket yang user_id-nya NULL ke system user
UPDATE tickets
SET user_id = '00000000-0000-0000-0000-000000000001'
WHERE user_id IS NULL;

-- 4. Update tiket yang user_id-nya lama ke system user dulu
-- (supaya bisa dilihat, nanti bisa di-update ke user yang sebenarnya)
UPDATE tickets
SET user_id = '00000000-0000-0000-0000-000000000001'
WHERE user_id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7'
  AND NOT EXISTS (
    SELECT 1 FROM users WHERE id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7'
  );

-- 5. Update comments juga
UPDATE comments
SET user_id = '00000000-0000-0000-0000-000000000001'
WHERE user_id IS NULL
  OR (user_id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7'
       AND NOT EXISTS (
         SELECT 1 FROM users WHERE id = 'cd4e9b28-3ca6-4769-abdc-f950a6ab11e7'
       ));

-- 6. Cek hasil
SELECT '=== TIKET ===' as info;
SELECT id, ticket_no, title, user_id FROM tickets LIMIT 5;

SELECT '=== USERS ===' as info;
SELECT id, email, name, role FROM users;

-- 7. Setelah login sebagai user yang sebenarnya, update tiket ke user tersebut:
-- UPDATE tickets SET user_id = 'USER_ID_BARU' WHERE user_id = '00000000-0000-0000-0000-000000000001';
-- UPDATE comments SET user_id = 'USER_ID_BARU' WHERE user_id = '00000000-0000-0000-0000-000000000001';
