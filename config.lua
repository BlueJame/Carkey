Config = {}

Config.LockDistance = 15 -- ระยะการล็อก

Config.Webhooks = {
    sendToDiscordsource = "YOUR_SOURCE_WEBHOOK_URL",  -- ใส่ URL ของ Webhook ส่งกุญแจรถทะเบียน
    sendToDiscordtarget = "YOUR_TARGET_WEBHOOK_URL"   -- ใส่ URL ของ Webhook ได้รับกุญแจรถทะเบียน
}

Config.LockColor = { r = 255, g = 0, b = 0, a = 255 }    -- สีแดงสำหรับการล็อกรถ
Config.UnlockColor = { r = 0, g = 255, b = 0, a = 255 }  -- สีเขียวสำหรับการปลดล็อกรถ
Config.OutlineTime = 3000 -- เวลาการแสดงผล outline (มิลลิวินาที) 1000 ต่อ 1 วิ
Config.cooldown = 4000

Config.EnableOutline = true -- เปิดหรือปิดการแสดง outline
Config.EnableMarker = true -- เปิดหรือปิดการแสดง marker

Config.Slow = true -- ลดหน่วงถ้าปิด Marker จะไม่กระพิบ