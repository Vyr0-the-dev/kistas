import os
import sys

# Try importing PIL
try:
    from PIL import Image
except ImportError:
    print("Pillow not found. Please run 'pip install Pillow' in your venv.")
    sys.exit(1)

def pad_image():
    source_path = 'assets/images/notification_icon.png'
    target_path = 'android/app/src/main/res/drawable/ic_launcher_white_text.png'
    
    if not os.path.exists(source_path):
        print(f"Error: {source_path} not found.")
        return

    print(f"Processing {source_path}...")
    
    # Orijinal görseli aç
    img = Image.open(source_path).convert("RGBA")
    
    # Yeni bir kanvas oluştur (512x512 standarttır)
    canvas_size = (512, 512)
    new_img = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    
    # Orijinal görseli güvenli alana sığacak şekilde küçült
    # Boyutu 260px yapıyoruz (512'nin yaklaşık %50'si). 
    # Bu, hem taşmayı önler hem de ikonun çok küçük görünmesini engeller.
    target_width = 260
    w_percent = (target_width / float(img.size[0]))
    h_size = int((float(img.size[1]) * float(w_percent)))
    
    img_resized = img.resize((target_width, h_size), Image.Resampling.LANCZOS)
    
    # Ortaya yerleştir
    x_offset = (canvas_size[0] - img_resized.width) // 2
    y_offset = (canvas_size[1] - img_resized.height) // 2
    
    new_img.paste(img_resized, (x_offset, y_offset), img_resized)
    
    # Kaydet
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    new_img.save(target_path)
    print(f"Success: Padded icon saved to {target_path}")

if __name__ == "__main__":
    pad_image()