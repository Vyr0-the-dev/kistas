import os
from PIL import Image

def resize_balanced():
    source = 'assets/images/notification_icon.png'
    target = 'android/app/src/main/res/drawable/notification_icon.png'
    
    if not os.path.exists(source):
        print(f"Error: {source} not found")
        return

    img = Image.open(source).convert("RGBA")
    bbox = img.getbbox()
    if not bbox:
        return
        
    # İçeriği kırp
    content = img.crop(bbox)
    
    # 512x512 standart kanvas oluştur
    canvas_size = 512
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    
    # Logoyu kanvasın %75'i olacak şekilde ayarla (yaklaşık 384px)
    # Bu oran yanındaki sistem ikonlarıyla (pil, wifi vb.) uyumlu durmasını sağlar
    target_dim = 384 
    
    w, h = content.size
    if w > h:
        new_w = target_dim
        new_h = int(h * (target_dim / w))
    else:
        new_h = target_dim
        new_w = int(w * (target_dim / h))
        
    content_resized = content.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    # Kanvasın tam ortasına yerleştir
    offset = ((canvas_size - new_w) // 2, (canvas_size - new_h) // 2)
    canvas.paste(content_resized, offset, content_resized)
    
    canvas.save(target)
    print(f"Success: Balanced icon saved to {target}")

if __name__ == "__main__":
    resize_balanced()